output "lambda_function_arn" {
  description = "The ARN of the deployed Lambda function."
  value       = module.lambda.lambda_function_arn
}
