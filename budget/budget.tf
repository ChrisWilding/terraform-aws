data "aws_iam_policy_document" "budget" {
  statement {
    actions = [
      "SNS:Publish",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["budgets.amazonaws.com"]
    }

    resources = [aws_sns_topic.budget.arn]
  }
}

resource "aws_sns_topic" "budget" {
  name = "budget"
}

resource "aws_sns_topic_policy" "budget" {
  arn = aws_sns_topic.budget.arn

  policy = data.aws_iam_policy_document.budget.json
}

resource "aws_sns_topic_subscription" "budget" {
  topic_arn = aws_sns_topic.budget.arn
  protocol  = "sms"
  endpoint  = "+447828835419"
}


resource "aws_budgets_budget" "budget" {
  name              = "budget"
  budget_type       = "COST"
  limit_amount      = "25"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2021-07-01_00:00"

  notification {
    notification_type          = "ACTUAL"
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    subscriber_email_addresses = ["hello@chriswilding.co.uk"]
    subscriber_sns_topic_arns  = ["${aws_sns_topic.budget.arn}"]
  }
}
