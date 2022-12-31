module "channel_post_api" {
  source  = "git@github.com:ada-powerful/tf-basic-modules.git//private_api"
  api_id               = var.api_id
  api_resource_id      = "${aws_api_gateway_resource.channel.id}"
  http_method          = "POST"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = "${var.authorizer_id}"
  lambda_function_arn  = var.lambda_function_arn
  request_parameters   = {
                           "method.request.header.Authorization"  = true
                         }
  request_validator_id = var.request_validator_id
  request_models       = {
                           "application/json" = aws_api_gateway_model.channels_channel_post_model.name
                         }
  response_models      = {}
}

resource "aws_api_gateway_model" "channels_channel_post_model" {
  rest_api_id  = var.api_id
  name         = "channelschannelpost"
  description  = "A JSON schema for POST /channels/{channel_type_and_account_id}"
  content_type = "application/json"
  schema       = file("${path.module}/request_schemas/channel_post.json")
}

