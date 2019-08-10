variable "aws_profile" {
  type        = string
  default     = "default"
  description = "Name of configured AWS profile to use for Lambda provision"
}

variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "Region where to provision Lambda"
}

variable "pip_path" {
  type        = string
  default     = "/usr/local/bin/pip"
  description = "Path to your pip installation"
}

variable "lambda_name" {
  type        = string
  default     = "lambda_test"
  description = "Lambda function name"
}

variable "lambda_iam_name" {
  type        = string
  default     = "lambda_iam"
  description = "Name of IAM for Lambda"
}

variable "lambda_api_name" {
  type        = string
  default     = "lambda_api"
  description = "Name of API Gateway for Lambda"
}

variable "api_stage_name" {
  type        = string
  default     = "dev"
  description = "API Gateway Stage"
}

variable "api_resource_path" {
  type        = string
  default     = "lambda_resource"
  description = "API Gateway Path"
}

variable "api_http_method" {
  type        = string
  default     = "GET"
  description = "Method to trigger Lambda through API Gateway"
}

variable "iam_additional_policy" {
  type        = string
  default     = ""
  description = "Additional IAM Policy for Lambda function"
}
