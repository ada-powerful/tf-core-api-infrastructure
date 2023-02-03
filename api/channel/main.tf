locals {
  resource_name           = "channels"
  leaf_resource_name      = "channel_type_and_account_id"
  level_one_http_methods  = ["GET", "POST", "DELETE"]
  level_two_http_methods  = ["GET", "POST", "PATCH", "DELETE"]
}

resource "aws_lambda_permission" "channels" {
  for_each = toset( local.level_one_http_methods )

  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${var.api_execution_arn}/*/${each.key}/${local.resource_name}"
}

resource "aws_lambda_permission" "channel" {
  for_each = toset( local.level_two_http_methods )

  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${var.api_execution_arn}/*/${each.key}/${local.resource_name}/{${local.leaf_resource_name}}"
}

resource "aws_api_gateway_resource" "channels" {
  rest_api_id = var.api_id
  parent_id   = var.root_resource_id
  path_part   = local.resource_name
}

resource "aws_api_gateway_resource" "channel" {
  rest_api_id = var.api_id
  parent_id   = aws_api_gateway_resource.channels.id
  path_part   = "{${local.leaf_resource_name}}"
}

module "api-gateway-enable-cors-channels" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = var.api_id
  api_resource_id = aws_api_gateway_resource.channels.id
}

module "api-gateway-enable-cors-channel" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = var.api_id
  api_resource_id = aws_api_gateway_resource.channel.id
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    module.channels_get_api,
    module.channels_post_api,
    module.channels_delete_api,
    module.channel_get_api,
    module.channel_post_api,
    module.channel_patch_api,
    module.channel_delete_api
  ]

  rest_api_id = var.api_id
  stage_name  = "prod"
}

