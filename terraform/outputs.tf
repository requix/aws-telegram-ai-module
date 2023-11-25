output "apigateway_endpoint" {
  description = "The URI of the API"
  value       = try(module.api_gateway.apigatewayv2_api_api_endpoint, "")
}
