# terraform/lambda/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = var.aws_region # Using a variable for flexibility
}

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = var.lambda_function_name
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime

  memory_size   = var.lambda_memory
  timeout       = var.lambda_timeout

  source_path   = "${path.module}/src/lambda"

  # Optionally, set environment variables
  # environment_variables = {
  #   MY_ENV_VAR = "some_value"
  # }

  tags = {
    Environment = "NuonManaged"
    Project     = "SimpleLambda"
  }
}

output "lambda_function_arn" {
  description = "The ARN of the deployed Lambda function."
  value       = module.lambda.lambda_function_arn
}
