resource "aws_sqs_queue" "inbound" {
  name_prefix               = "${var.app_name}-inbound-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  #We recommend setting your queue visibility timeout to six times your function timeout, plus the value of MaximumBatchingWindowInSeconds. 
  #https://repost.aws/questions/QUcf-HhoKhSsG59sXaFagHiw/what-if-a-lambda-function-fails-to-process-an-sqs-message-within-the-visibility-timeout-of-the-queue
  visibility_timeout_seconds        = 360
  kms_master_key_id                 = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = 300

  tags = {
    Name = "${var.app_name}-queue"
  }
}
