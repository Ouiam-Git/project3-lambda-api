output "api_endpoint" {
  description = "Live HTTP endpoint for the API"
  value       = "${aws_apigatewayv2_stage.default.invoke_url}/hello"
}

output "lambda_function_name" {
  description = "Deployed Lambda function name"
  value       = aws_lambda_function.api.function_name
}

output "lambda_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.api.arn
}
