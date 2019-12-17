# Backend S3 + Dynamo DB for locking
terraform {
  backend "s3" {
    bucket         = "results-glue-tests"
    key            = "results-glue-tests/terraform.tfstate"
    region         = "eu-west-2" # NB: No var usage allowed in in backend setup
    dynamodb_table = "results-glue-tests"
    encrypt        = true
  }
}
