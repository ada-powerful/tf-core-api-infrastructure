locals {
  resource_name           = "operators"
  leaf_resource_name      = "operator_name"
  level_one_http_methods  = ["GET", "POST", "DELETE"]
  level_two_http_methods  = ["GET", "PATCH", "DELETE"]
}

resource "aws_lambda_permission" "operators" {
  for_each = toset( local.level_one_http_methods )

  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${var.api_execution_arn}/*/${each.key}/${local.resource_name}"
}

resource "aws_lambda_permission" "operator" {
  for_each = toset( local.level_two_http_methods )

  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${var.api_execution_arn}/*/${each.key}/${local.resource_name}/{${local.leaf_resource_name}}"
}

resource "aws_api_gateway_resource" "operators" {
  rest_api_id = var.api_id
  parent_id   = var.root_resource_id
  path_part   = local.resource_name
}

resource "aws_api_gateway_resource" "operator" {
  rest_api_id = var.api_id
  parent_id   = aws_api_gateway_resource.operators.id
  path_part   = "{${local.leaf_resource_name}}"
}

module "api-gateway-enable-cors-operators" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = var.api_id
  api_resource_id = aws_api_gateway_resource.operators.id
}

module "api-gateway-enable-cors-operator" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = var.api_id
  api_resource_id = aws_api_gateway_resource.operator.id
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    module.operators_get_api,
    module.operators_post_api,
    module.operators_delete_api,
    module.operator_get_api,
    module.operator_patch_api,
    module.operator_delete_api
  ]

  rest_api_id = var.api_id
  stage_name  = "prod"
}

