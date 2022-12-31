locals {
  resource_name           = "categories"
  leaf_resource_name      = "channel_type_and_account_id"
  level_one_http_methods  = ["GET", "POST", "DELETE"]
  level_two_http_methods  = ["GET", "POST", "DELETE"]
}

resource "aws_lambda_permission" "categories" {
  for_each = toset( local.level_one_http_methods )

  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${var.api_execution_arn}/*/${each.key}/${local.resource_name}"
}

resource "aws_lambda_permission" "category" {
  for_each = toset( local.level_two_http_methods )

  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${var.api_execution_arn}/*/${each.key}/${local.resource_name}/{${local.leaf_resource_name}}"
}

resource "aws_api_gateway_resource" "categories" {
  rest_api_id = var.api_id
  parent_id   = var.root_resource_id
  path_part   = local.resource_name
}

resource "aws_api_gateway_resource" "category" {
  rest_api_id = var.api_id
  parent_id   = aws_api_gateway_resource.categories.id
  path_part   = "{${local.leaf_resource_name}}"
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    module.categories_get_api,
    module.categories_post_api,
    module.categories_delete_api,
    module.category_get_api,
    module.category_post_api,
    module.category_delete_api
  ]

  rest_api_id = var.api_id
  stage_name  = "prod"
}

