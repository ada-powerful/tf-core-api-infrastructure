locals {
  resource_name           = "prompts"
  leaf_resource_name      = "prompt_id"
  level_one_http_methods  = ["GET", "POST", "DELETE"]
  level_two_http_methods  = ["GET", "DELETE"]
}

resource "aws_lambda_permission" "prompts" {
  for_each = toset( local.level_one_http_methods )

  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${var.api_execution_arn}/*/${each.key}/${local.resource_name}"
}

resource "aws_lambda_permission" "prompt" {
  for_each = toset( local.level_two_http_methods )

  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${var.api_execution_arn}/*/${each.key}/${local.resource_name}/{${local.leaf_resource_name}}"
}

resource "aws_api_gateway_resource" "prompts" {
  rest_api_id = var.api_id
  parent_id   = var.root_resource_id
  path_part   = local.resource_name
}

resource "aws_api_gateway_resource" "prompt" {
  rest_api_id = var.api_id
  parent_id   = aws_api_gateway_resource.prompts.id
  path_part   = "{${local.leaf_resource_name}}"
}

module "api-gateway-enable-cors-prompts" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = var.api_id
  api_resource_id = aws_api_gateway_resource.prompts.id
}

module "api-gateway-enable-cors-prompt" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = var.api_id
  api_resource_id = aws_api_gateway_resource.prompt.id
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    module.prompts_get_api,
    module.prompts_post_api,
    module.prompts_delete_api,
    module.prompt_get_api,
    module.prompt_delete_api
  ]

  rest_api_id = var.api_id
  stage_name  = "prod"
}

