resource "aws_api_gateway_rest_api" "site_core_api_gateway" {
  name        = "SiteCoreAPIGateway"
  description = "API Gateway for core APIs to support channels"
}

resource "aws_api_gateway_authorizer" "authorizer" {
  name          = "CoolAPIAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.site_core_api_gateway.id
  provider_arns = ["${var.user_pool_provider_arns}"]
}

resource "aws_api_gateway_request_validator" "core_api_request_validator" {
  name                        = "core_api_request_validator"
  rest_api_id                 = aws_api_gateway_rest_api.site_core_api_gateway.id
  validate_request_body       = true
  validate_request_parameters = true
}

module "channel_api" {
  source  = "./api/channel"
  
  api_id               = "${aws_api_gateway_rest_api.site_core_api_gateway.id}"
  api_execution_arn    = "${aws_api_gateway_rest_api.site_core_api_gateway.execution_arn}"
  root_resource_id     = "${aws_api_gateway_rest_api.site_core_api_gateway.root_resource_id}"
  lambda_function_arn  = "${aws_lambda_function.channels.invoke_arn}"
  lambda_function_name = "${aws_lambda_function.channels.function_name}"
  authorizer_id        =  "${aws_api_gateway_authorizer.authorizer.id}"
  request_validator_id = "${aws_api_gateway_request_validator.core_api_request_validator.id}"
}

module "category_api" {
  source  = "./api/category"
  
  api_id               = "${aws_api_gateway_rest_api.site_core_api_gateway.id}"
  api_execution_arn    = "${aws_api_gateway_rest_api.site_core_api_gateway.execution_arn}"
  root_resource_id     = "${aws_api_gateway_rest_api.site_core_api_gateway.root_resource_id}"
  lambda_function_arn  = "${aws_lambda_function.categories.invoke_arn}"
  lambda_function_name = "${aws_lambda_function.categories.function_name}"
  authorizer_id        =  "${aws_api_gateway_authorizer.authorizer.id}"
  request_validator_id = "${aws_api_gateway_request_validator.core_api_request_validator.id}"
}

module "article_api" {
  source  = "./api/article"
  
  api_id               = "${aws_api_gateway_rest_api.site_core_api_gateway.id}"
  api_execution_arn    = "${aws_api_gateway_rest_api.site_core_api_gateway.execution_arn}"
  root_resource_id     = "${aws_api_gateway_rest_api.site_core_api_gateway.root_resource_id}"
  lambda_function_arn  = "${aws_lambda_function.articles.invoke_arn}"
  lambda_function_name = "${aws_lambda_function.articles.function_name}"
  authorizer_id        =  "${aws_api_gateway_authorizer.authorizer.id}"
  request_validator_id = "${aws_api_gateway_request_validator.core_api_request_validator.id}"
}

module "packager_api" {
  source  = "./api/packager"
  
  api_id               = "${aws_api_gateway_rest_api.site_core_api_gateway.id}"
  api_execution_arn    = "${aws_api_gateway_rest_api.site_core_api_gateway.execution_arn}"
  root_resource_id     = "${aws_api_gateway_rest_api.site_core_api_gateway.root_resource_id}"
  lambda_function_arn  = "${aws_lambda_function.packager.invoke_arn}"
  lambda_function_name = "${aws_lambda_function.packager.function_name}"
  authorizer_id        =  "${aws_api_gateway_authorizer.authorizer.id}"
  request_validator_id = "${aws_api_gateway_request_validator.core_api_request_validator.id}"
}
