resource "aws_iam_group" "administrators" {
  name = "administrators"
}

resource "aws_iam_group_policy_attachment" "administrators" {
  group      = aws_iam_group.administrators.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user" "administrator" {
  name = "administrator"
}

resource "aws_iam_user_group_membership" "administrator" {
  user = aws_iam_user.administrator.name

  groups = [
    aws_iam_group.administrators.name
  ]
}

data "aws_iam_policy_document" "permissions_boundary" {
  statement {
    condition {
      test     = "StringNotEquals"
      values   = ["eu-west-1"]
      variable = "aws:RequestedRegion"
    }

    effect = "Deny"

    not_actions = [
      "cloudfront:*",
      "iam:*",
      "route53:*",
      "support:*"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "cloudfront:*",
      "iam:*",
      "route53:*",
      "support:*"
    ]

    effect = "Allow"

    resources = ["*"]
  }

  statement {
    condition {
      test     = "StringEquals"
      values   = ["eu-west-1"]
      variable = "aws:RequestedRegion"
    }

    effect = "Allow"

    not_actions = [
      "cloudfront:*",
      "iam:*",
      "route53:*",
      "support:*"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "account:*",
      "aws-portal:*",
      "ce:*",
      "cur:*",
      "savingsplans:*",
    ]

    effect = "Deny"

    resources = ["*"]
  }

  statement {
    actions = [
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:CreatePolicyVersion",
      "iam:SetDefaultPolicyVersion"
    ]

    effect = "Deny"

    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionsBoundary"]
  }

  statement {
    actions = [
      "iam:DeleteUserPermissionsBoundary",
      "iam:DeleteRolePermissionsBoundary"
    ]

    condition {
      test     = "StringEquals"
      values   = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionsBoundary"]
      variable = "iam:PermissionsBoundary"
    }

    effect = "Deny"

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
    ]
  }

  statement {
    actions = [
      "iam:PutUserPermissionsBoundary",
      "iam:PutRolePermissionsBoundary"
    ]

    condition {
      test     = "StringNotEquals"
      values   = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionsBoundary"]
      variable = "iam:PermissionsBoundary"
    }

    effect = "Deny"

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
    ]
  }

  statement {
    actions = [
      "iam:CreateUser",
      "iam:CreateRole"
    ]

    condition {
      test     = "StringNotEquals"
      values   = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionsBoundary"]
      variable = "iam:PermissionsBoundary"
    }

    effect = "Deny"

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
    ]
  }
}

resource "aws_iam_policy" "permissions_boundary" {
  name = "PermissionsBoundary"

  policy = data.aws_iam_policy_document.permissions_boundary.json
}

resource "aws_iam_group" "developers" {
  name = "developers"
}

resource "aws_iam_group_policy_attachment" "developers" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user" "developer" {
  name = "developer"

  permissions_boundary = aws_iam_policy.permissions_boundary.arn
}

resource "aws_iam_user_group_membership" "developer" {
  user = aws_iam_user.developer.name

  groups = [
    aws_iam_group.developers.name,
  ]
}
