locals {
  resource_name           = "topics"
  leaf_resource_name      = "topic_id"
  level_one_http_methods  = ["GET", "POST", "DELETE"]
  level_two_http_methods  = ["GET", "PATCH", "DELETE"]
}

resource "aws_lambda_permission" "topics" {
  for_each = toset( local.level_one_http_methods )

  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${var.api_execution_arn}/*/${each.key}/${local.resource_name}"
}

resource "aws_lambda_permission" "topic" {
  for_each = toset( local.level_two_http_methods )

  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${var.api_execution_arn}/*/${each.key}/${local.resource_name}/{${local.leaf_resource_name}}"
}

resource "aws_api_gateway_resource" "topics" {
  rest_api_id = var.api_id
  parent_id   = var.root_resource_id
  path_part   = local.resource_name
}

resource "aws_api_gateway_resource" "topic" {
  rest_api_id = var.api_id
  parent_id   = aws_api_gateway_resource.topics.id
  path_part   = "{${local.leaf_resource_name}}"
}

module "api-gateway-enable-cors-topics" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = var.api_id
  api_resource_id = aws_api_gateway_resource.topics.id
}

module "api-gateway-enable-cors-topic" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = var.api_id
  api_resource_id = aws_api_gateway_resource.topic.id
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    module.topics_get_api,
    module.topics_post_api,
    module.topics_delete_api,
    module.topic_get_api,
    module.topic_patch_api,
    module.topic_delete_api
  ]

  rest_api_id = var.api_id
  stage_name  = "prod"
}

