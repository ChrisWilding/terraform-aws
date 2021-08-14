data "aws_iam_policy_document" "new_relic_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.new_relic_account_id]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.new_relic_aws_account_id}:root"]
    }
  }
}

resource "aws_iam_role" "new_relic" {
  name = "new-relic-infrastructure-integration"

  assume_role_policy   = data.aws_iam_policy_document.new_relic_assume_role.json
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionsBoundary"
}

resource "aws_iam_role_policy_attachment" "new_relic" {
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  role       = aws_iam_role.new_relic.name
}

data "aws_iam_policy_document" "new_relic_view_budget" {
  statement {
    actions = [
      "budgets:ViewBudget",
    ]

    effect = "Allow"

    resources = ["*"]
  }
}

resource "aws_iam_policy" "new_relic_view_budget" {
  name   = "new-relic-view-budget"
  policy = data.aws_iam_policy_document.new_relic_view_budget.json
}

resource "aws_iam_role_policy_attachment" "new_relic_view_budget" {
  role       = aws_iam_role.new_relic.name
  policy_arn = aws_iam_policy.new_relic_view_budget.arn
}

