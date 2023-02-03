output "authorizer_id" {
  value       = aws_api_gateway_authorizer.authorizer.id
  description = "The id of the API authorizer."
}

output "root_resource_id" {
  value       = aws_api_gateway_rest_api.site_core_api_gateway.root_resource_id
  description = "The root resource id of the Rest API."
}

output "api_id" {
  value       = aws_api_gateway_rest_api.site_core_api_gateway.id
  description = "The id of the Rest API."
}

output "api_execution_arn" {
  value       = aws_api_gateway_rest_api.site_core_api_gateway.execution_arn
  description = "The execution arn of the Rest API."
}

output "request_validator_id" {
  value       = aws_api_gateway_request_validator.core_api_request_validator.id
  description = "Therequest validator id of the Rest API."
}

