resource "aws_iam_role" "main" {
  name = "${var.app_name}-sqs-send-message-for-telegram-bot"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "sqs-send-message-for-telegram-bot"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "sqs:SendMessage"
          ],
          "Effect" : "Allow",
          "Resource" : aws_sqs_queue.inbound.arn
        }
      ]
      }
    )
  }
}
