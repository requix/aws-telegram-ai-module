resource "aws_ssm_parameter" "bot-token" {
  name   = "${var.app_name}-bot-token"
  type   = "SecureString"
  key_id = "alias/aws/ssm"
  value  = "CHANGE-ME"

  tags = {
    Name = "${var.app_name}-ssm"
  }

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "openai-token" {
  name   = "${var.app_name}-openai-token"
  type   = "SecureString"
  key_id = "alias/aws/ssm"
  value  = "CHANGE-ME"

  tags = {
    Name = "${var.app_name}-ssm"
  }

  lifecycle {
    ignore_changes = [value]
  }
}
