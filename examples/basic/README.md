# Basic Python Lambda function example

Configuration in this directory deploys simple python script to AWS Lambda. Script writes all requests into cloudwatch logs.

## Usage

To run this example you need to execute:
```bash
$ terraform init
$ terraform plan -out=basic.tfplan
$ terraform apply -auto-approve basic.tfplan
```

Note that this configuration might create resources which cost money. Run `terraform destroy` when you don't need these resources anymore.

## Outputs

| Name | Description |
|------|-------------|
| api\_gateway | The API Gateway for receiving webhooks by Lambda function |

## Test

Send POST request to `<api_gateway>` url to test Lambda function. If you send data using flag `-d <data>` you should receive same data as a response. 
```bash
$ curl -X POST -d pong <api_gateway>

"pong"
```
