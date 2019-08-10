provider "aws" {
  profile = "${var.aws_profile}"
  region = "${var.aws_region}"
}

# This will fetch our account_id, no need to hard code it
data "aws_caller_identity" "current" {}

# Prepare Lambda package (https://github.com/hashicorp/terraform/issues/8344#issuecomment-345807204)
resource "null_resource" "pip" {
  triggers = {
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
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations"
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
  source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.lambda_api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
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

resource "aws_iam_role_policy" "additional_policy" {
  count = "${var.iam_additional_policy != "" ? 1 : 0}"

  name = "${var.lambda_iam_name}-additional-policy"
  role = "${aws_iam_role.lambda_iam.id}"

  policy = "${var.iam_additional_policy}"
}

# CloudWatch 
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${var.lambda_name}"

  retention_in_days = 30
}
