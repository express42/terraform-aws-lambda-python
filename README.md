# Terraform module for AWS Lambda Python function deployment

Terraform module which prepares and deploys python lambda function and prepares all necessities for it in AWS infrastructure.

## Features 
* Downloads python dependencies from requirements.txt to `lambda/lib` directory
* Archives lambda function with all dependencies into `lambda.zip`
* Creates IAM policy, lambda function, API Gateway and CloudWatch log group
* Creates IAM policy with additional rules
* Deploy lambda function
* Possible to use with python virtualenv

## Usage

### Preparation
* Put logic into `lambda_handler` in `lambda/main.py`
* Put your Lambda function requirements into `requirements.txt`

### Configuration example
```hcl
module "lambda_python" {
  source            = "express42/lambda-python/aws"

  aws_profile       = "default"
  aws_region        = "eu-west-1"

  pip_path          = "/usr/bin/pip"

  lambda_name       = "lambda_example"
  lambda_api_name   = "lambda_example_api"
  lambda_iam_name   = "lambda_example_iam"

  api_stage_name    = "dev"
  api_resource_path = "example"
  api_http_method   = "POST"
  
  iam_additional_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ],
        "Resource": "arn:aws:dynamodb:*"
      }
    ]
  }
  POLICY
}

output "lambda_url" {
  value = "${module.lambda_python.url}"
}
```

## Examples
* [Basic Example](https://github.com/express42/terraform-aws-lambda-python/tree/master/examples/basic) shows the simplest way to use this module
