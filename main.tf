provider "aws" {
  profile = "default"
  region = "${var.region}"
}

# This will fetch our account_id, no need to hard code it
data "aws_caller_identity" "current" {}

# Variables
variable "region" {
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
  default = "resource"
}

variable "api_http_method" {
  default = "GET"
}

# Prepare Lambda package (https://github.com/hashicorp/terraform/issues/8344#issuecomment-345807204)
resource "null_resource" "pip" {
  triggers {
    main         = "${base64sha256(file("lambda/main.py"))}"
    requirements = "${base64sha256(file("requirements.txt"))}"
  }

  provisioner "local-exec" {
    command = "${var.pip_path} install -r ${path.root}/requirements.txt -t lambda/lib"
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/lambda/"
  output_path = "${path.root}/lambda.zip"

  depends_on = ["null_resource.pip"]
}

# API Gateway
resource "aws_api_gateway_rest_api" "lambda_api" {
  name = "${var.lambda_api_name}"
}

resource "aws_api_gateway_resource" "resource" {
  path_part = "${var.api_resource_path}"
  parent_id = "${aws_api_gateway_rest_api.lambda_api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.lambda_api.id}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.lambda_api.id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "${var.api_http_method}"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.lambda_api.id}"
  resource_id             = "${aws_api_gateway_resource.resource.id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = ["aws_api_gateway_integration.integration"]

  rest_api_id = "${aws_api_gateway_rest_api.lambda_api.id}"
  stage_name  = "${var.api_stage_name}"
}

# Lambda
resource "aws_lambda_permission" "lambda_apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.lambda_api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}

resource "aws_lambda_function" "lambda" {
  filename         = "lambda.zip"
  function_name    = "${var.lambda_name}"
  role             = "${aws_iam_role.lambda_iam.arn}"
  handler          = "main.lambda_handler"
  runtime          = "python3.6"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
}

# IAM
resource "aws_iam_role" "lambda_iam" {
  name = "${var.lambda_iam_name}"

  assume_role_policy = "${file("${path.module}/policy.json")}"
}

resource "aws_iam_role_policy_attachment" "logs_policy" {
    role       = "${aws_iam_role.lambda_iam.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Output
output "url" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}${aws_api_gateway_resource.resource.path}"
}