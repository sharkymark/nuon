variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "lambda_function_name" {
  description = "The name of the Lambda function."
  type        = string
  default     = "my-nuon-terraform-lambda"
}

variable "lambda_handler" {
  description = "The function entrypoint in the Lambda code."
  type        = string
  default     = "index.handler"
}

variable "lambda_runtime" {
  description = "The runtime for the Lambda function (e.g., python3.9)."
  type        = string
  default     = "python3.9"
}

variable "lambda_memory" {
  description = "The amount of memory allocated to the Lambda function (MB)."
  type        = number
  default     = 128
}

variable "lambda_timeout" {
  description = "The maximum execution time for the Lambda function (seconds)."
  type        = number
  default     = 30
}