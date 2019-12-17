variable "region" {
  description = "AWS region"
  default = "eu-west-2"
}

variable "common_tags" {
  default = {
    "ons:environment" = "development",
    "ons:application" = "results-glue-tests",
  }
}
