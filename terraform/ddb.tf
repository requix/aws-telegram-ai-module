resource "aws_dynamodb_table" "assistant" {
  name           = "${var.app_name}-assistant"
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "assistant_id"

  attribute {
    name = "assistant_id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamo-encryption-key.arn
  }
}


resource "aws_dynamodb_table" "threads" {
  name           = "${var.app_name}-threads"
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "chat_id"
  range_key      = "thread_id"

  attribute {
    name = "chat_id"
    type = "N"
  }

  attribute {
    name = "thread_id"
    type = "S"
  }

  attribute {
    name = "thread_status"
    type = "S"
  }

  global_secondary_index {
    name               = "UserStatusIndex"
    hash_key           = "chat_id"
    range_key          = "thread_status"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "INCLUDE"
    non_key_attributes = ["thread_name"]
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamo-encryption-key.arn
  }
}
