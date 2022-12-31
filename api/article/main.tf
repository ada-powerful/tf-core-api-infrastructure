locals {
  resource_name           = "articles"
  leaf_resource_name      = "article_id"
  level_one_http_methods  = ["GET", "POST", "DELETE"]
  level_two_http_methods  = ["GET", "PATCH", "DELETE"]
}

resource "aws_lambda_permission" "articles" {
  for_each = toset( local.level_one_http_methods )

  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${var.api_execution_arn}/*/${each.key}/${local.resource_name}"
}

resource "aws_lambda_permission" "article" {
  for_each = toset( local.level_two_http_methods )

  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${var.api_execution_arn}/*/${each.key}/${local.resource_name}/{${local.leaf_resource_name}}"
}

resource "aws_api_gateway_resource" "articles" {
  rest_api_id = var.api_id
  parent_id   = var.root_resource_id
  path_part   = local.resource_name
}

resource "aws_api_gateway_resource" "article" {
  rest_api_id = var.api_id
  parent_id   = aws_api_gateway_resource.articles.id
  path_part   = "{${local.leaf_resource_name}}"
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    module.articles_get_api,
    module.articles_post_api,
    module.articles_delete_api,
    module.article_get_api,
    module.article_patch_api,
    module.article_delete_api
  ]

  rest_api_id = var.api_id
  stage_name  = "prod"
}

