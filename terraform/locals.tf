locals {
  region     = data.aws_region.current-region.name
  account_id = data.aws_caller_identity.current-account.id
}
