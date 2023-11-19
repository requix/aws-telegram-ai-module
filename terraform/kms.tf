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
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current-account.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
          "Sid": "Allow use of the key for Lambda IAM role",
          "Effect": "Allow",
          "Principal": {"AWS": [
            "arn:aws:iam::${data.aws_caller_identity.current-account.account_id}:role/terraform-cloudwatch-log-management-lambda-role"
          ]},
          "Action": [
            "kms:DescribeKey"
          ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.${data.aws_region.current-region.name}.amazonaws.com"
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
                    "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${data.aws_region.current-region.name}:${data.aws_caller_identity.current-account.account_id}:*:*"
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
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current-account.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
          "Sid": "Allow use of the key for Lambda IAM role",
          "Effect": "Allow",
          "Principal": {"AWS": [
            "arn:aws:iam::${data.aws_caller_identity.current-account.account_id}:role/terraform-cloudwatch-log-management-lambda-role"
          ]},
          "Action": [
            "kms:DescribeKey"
          ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.${data.aws_region.current-region.name}.amazonaws.com"
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
                    "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${data.aws_region.current-region.name}:${data.aws_caller_identity.current-account.account_id}:*:*"
                }
            }
        }
    ]
}
EOF
}
