module "lambda_python" {
  source            = "../../"

  aws_profile       = "default"
  aws_region        = "eu-west-1"

  pip_path          = ".venv/bin/pip"

  lambda_name       = "lambda_example"
  lambda_api_name   = "lambda_example_api"
  lambda_iam_name   = "lambda_example_iam"

  api_stage_name    = "dev"
  api_resource_path = "example"
  api_http_method   = "POST"
}
