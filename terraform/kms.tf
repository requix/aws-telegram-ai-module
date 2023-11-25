resource "aws_kms_key" "log-encryption-key" {
  description             = "Key for CloudWatch log encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = <<EOF
{
    "Version": "2012-10-17",
    "Id": "key-consolepolicy",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${local.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },       
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.${local.region}.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt*",
                "kms:Decrypt*",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Describe*"
            ],
            "Resource": "*",
            "Condition": {
                "ArnEquals": {
                    "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${local.region}:${local.account_id}:log-group:*"
                }
            }
        }
    ]
}
EOF
}

resource "aws_kms_key" "dynamo-encryption-key" {
  description             = "Key for DynamoDB encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = <<EOF
{
    "Version": "2012-10-17",
    "Id": "key-consolepolicy",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${local.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "dynamodb.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt*",
                "kms:Decrypt*",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Describe*"
            ],
            "Resource": "*",
            "Condition": {
                "ArnEquals": {
                    "kms:EncryptionContext:aws:dynamodb:arn": "arn:aws:dynamodb:${local.region}:${local.account_id}:table:*"
                }
            }
        }
    ]
}
EOF
}
