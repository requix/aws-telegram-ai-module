module "api_gateway" {
  #checkov:skip=CKV_TF_1
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "~> 2.0"

  name                   = "${var.app_name}-webhook"
  description            = "Telegram Webhook HTTP API Gateway"
  protocol_type          = "HTTP"
  create_api_domain_name = false

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.logs.arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  default_route_settings = {
    detailed_metrics_enabled = true
    throttling_burst_limit   = 100
    throttling_rate_limit    = 100
  }

  integrations = {
    "ANY /" = {
      integration_type    = "AWS_PROXY"
      integration_subtype = "SQS-SendMessage"
      credentials_arn     = aws_iam_role.main.arn
      description         = "SQS integration"

      request_parameters = {
        "QueueUrl"    = aws_sqs_queue.inbound.id
        "MessageBody" = "$request.body"
      }
    }
  }

  tags = {
    Name = "${var.app_name}-api-gtw"
  }
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "${var.app_name}-logs"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.log-encryption-key.id
}
