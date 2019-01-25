variable "aws_profile" {
  default = "default"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "pip_path" {}

variable "lambda_name" {
  default = "lambda_test"
}

variable "lambda_iam_name" {
  default = "lambda_iam"
}

variable "lambda_api_name" {
  default = "lambda_api"
}

variable "api_stage_name" {
  default = "dev"
}

variable "api_resource_path" {
  default = "lambda_resource"
}

variable "api_http_method" {
  default = "GET"
}
