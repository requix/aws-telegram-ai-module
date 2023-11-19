module "lambda_function" {
  #checkov:skip=CKV_TF_1
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 5.0"

  function_name = "${var.app_name}-messages-processing"
  description   = "This function performs processing inbound and outbound messages for telegram bot"
  handler       = "index.handler"
  runtime       = "python3.10"
  timeout       = 60

  publish = true

  source_path = "${path.module}/src/lambda/message-processing"

  event_source_mapping = {
    sqs = {
      event_source_arn = aws_sqs_queue.inbound.arn
      scaling_config = {
        maximum_concurrency = 20
      }
    }
  }

  allowed_triggers = {
    sqs = {
      principal  = "sqs.amazonaws.com"
      source_arn = aws_sqs_queue.inbound.arn
    }
  }

  create_current_version_allowed_triggers = false

  attach_network_policy = true

  attach_policies    = true
  number_of_policies = 1
  policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
  ]

  attach_policy_statements = true
  policy_statements = {
    sqs = {
      effect    = "Allow",
      actions   = ["sqs:SendMessage"],
      resources = [aws_sqs_queue.inbound.arn]
    },
    ssm = {
      effect  = "Allow",
      actions = ["ssm:GetParameter"],
      resources = [
        aws_ssm_parameter.bot-token.arn,
        aws_ssm_parameter.openai-token.arn,
      ]
    },
    ddb = {
      effect = "Allow",
      actions = [
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      resources = [
        "*"
      ]
    }
  }

  environment_variables = {
    telegram                = aws_ssm_parameter.bot-token.name
    openai                  = aws_ssm_parameter.openai-token.name
    assistant_table_name    = aws_dynamodb_table.assistant.id
    threads_table_name      = aws_dynamodb_table.threads.id
    allowed_users_ids       = join(",", var.allowed_users_ids)
    assistant_name          = var.assistant_name
    assistant_instructions  = var.assistant_instructions
    assistant_model         = var.assistant_model
    enable_code_interpreter = var.enable_code_interpreter
  }
}
