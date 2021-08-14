resource "aws_secretsmanager_secret" "new_relic" {
  name = "NEW_RELIC_LICENSE_KEY"
}

resource "aws_secretsmanager_secret_version" "new_relic" {
  secret_id = aws_secretsmanager_secret.new_relic.id
  secret_string = jsonencode({
    "LicenseKey" : "${var.new_relic_license_key}}",
    "NrAccountId" : "${var.new_relic_account_id}"
  })
}
