#outputs.tf
output "api-gateway-url" {
  value = aws_api_gateway_rest_api.apigateway.endpoint_configuration
}
