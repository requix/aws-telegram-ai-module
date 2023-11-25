resource "aws_cloudwatch_log_group" "logs" {
  name              = "${var.app_name}-apigtw-logs"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.log-encryption-key.arn
}
