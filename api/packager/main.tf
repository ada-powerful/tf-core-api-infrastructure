locals {
  resource_name           = "packager"
  level_one_http_methods  = ["POST"]
}

resource "aws_lambda_permission" "packager" {
  for_each = toset( local.level_one_http_methods )

  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${var.api_execution_arn}/*/${each.key}/${local.resource_name}"
}

resource "aws_api_gateway_resource" "packager" {
  rest_api_id = var.api_id
  parent_id   = var.root_resource_id
  path_part   = local.resource_name
}

module "api-gateway-enable-cors-packager" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = var.api_id
  api_resource_id = aws_api_gateway_resource.packager.id
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    module.packager_post_api
  ]

  rest_api_id = var.api_id
  stage_name  = "prod"
}

