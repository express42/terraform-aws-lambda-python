# Terraform backbone for AWS Lambda Python function 

## Using Python virtualenv
```
virtualenv venv --system-site-packages
```

## Preparation
* Put logic into `lambda_handler` in `lambda/main.py`
* Put your Lambda function requirements into `requirements.txt`
* Copy terraform config examples
```
cp backend.conf.example backend.conf
cp terraform.tfvars.example terraform.tfvars
```
* Edit `backend.conf` and `terraform.tfvars` to reflect your configuration
* Start using

## Usage
* Run configuration
```
terraform init -backend-config backend.conf
terraform plan
terraform apply
```