output "site_url" {
  value = "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "api_url" {
  value = aws_apigatewayv2_api.api.api_endpoint
}

output "db_endpoint" {
  value = aws_db_instance.main.address
}

output "migration_result" {
  value = aws_lambda_invocation.migrate.result
}
