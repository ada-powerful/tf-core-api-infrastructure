module "channels_post_api" {
  source  = "git@github.com:ada-powerful/tf-basic-modules.git//private_api"
  api_id               = var.api_id
  api_resource_id      = "${aws_api_gateway_resource.channels.id}"
  http_method          = "POST"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = "${var.authorizer_id}"
  lambda_function_arn  = var.lambda_function_arn
  request_parameters   = {
                           "method.request.header.Authorization"  = true
                         }
  request_validator_id = var.request_validator_id
  request_models       = {
                           "application/json" = aws_api_gateway_model.channels_post_model.name
                         }
  response_models      = {}
}

resource "aws_api_gateway_model" "channels_post_model" {
  rest_api_id  = var.api_id
  name         = "channelspost"
  description  = "A JSON schema for POST /channels"
  content_type = "application/json"
  schema       = file("${path.module}/request_schemas/channels_post.json")
}

