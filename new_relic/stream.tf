resource "random_string" "suffix" {
  length  = 10
  special = false
  upper   = false
}

resource "aws_s3_bucket" "new_relic" {
  bucket = "new-relic-${random_string.suffix.id}"

  acl = "private"

  lifecycle_rule {
    enabled = true

    expiration {
      days = 7
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "new_relic" {
  bucket = aws_s3_bucket.new_relic.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "new_relic_firehose_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "firehose_to_s3" {
  name = "new_relic-firehose-to-s3"

  assume_role_policy   = data.aws_iam_policy_document.new_relic_firehose_assume_role.json
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionsBoundary"
}

resource "aws_kinesis_firehose_delivery_stream" "new_relic_firehose" {
  name = "new-relic-firehose"

  destination = "http_endpoint"

  http_endpoint_configuration {
    access_key         = var.new_relic_license_key
    buffering_interval = 60
    buffering_size     = 1
    name               = "New Relic"
    role_arn           = aws_iam_role.firehose_to_s3.arn
    s3_backup_mode     = "FailedDataOnly"
    url                = "https://aws-api.eu01.nr-data.net/cloudwatch-metrics/v1"

    request_configuration {
      content_encoding = "GZIP"
    }
  }

  s3_configuration {
    bucket_arn         = aws_s3_bucket.new_relic.arn
    compression_format = "GZIP"
    role_arn           = aws_iam_role.firehose_to_s3.arn
  }

  server_side_encryption {
    enabled = true
  }
}

data "aws_iam_policy_document" "new_relic_metric_stream_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["streams.metrics.cloudwatch.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "metric_stream_to_firehose" {
  statement {
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]

    effect = "Allow"

    resources = [aws_kinesis_firehose_delivery_stream.new_relic_firehose.arn]
  }
}


resource "aws_cloudwatch_metric_stream" "new_relic" {
  name = "new-relic-metric-stream"

  firehose_arn  = aws_kinesis_firehose_delivery_stream.new_relic_firehose.arn
  output_format = "opentelemetry0.7"
  role_arn      = aws_iam_role.metric_stream_to_firehose.arn
}

resource "aws_iam_role" "metric_stream_to_firehose" {
  name = "metric-stream-to-firehose-role"

  assume_role_policy   = data.aws_iam_policy_document.new_relic_metric_stream_assume_role.json
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionsBoundary"
}

resource "aws_iam_role_policy" "metric_stream_to_firehose" {
  policy = data.aws_iam_policy_document.metric_stream_to_firehose.json
  role   = aws_iam_role.metric_stream_to_firehose.id
}
