module "channel_patch_api" {
  source  = "git@github.com:ada-powerful/tf-basic-modules.git//private_api"
  api_id               = var.api_id
  api_resource_id      = "${aws_api_gateway_resource.channel.id}"
  http_method          = "PATCH"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = "${var.authorizer_id}"
  lambda_function_arn  = var.lambda_function_arn
  request_parameters   = {
                           "method.request.header.Authorization"  = true
                         }
  request_validator_id = var.request_validator_id
  request_models       = {
                           "application/json" = aws_api_gateway_model.channels_channel_patch_model.name
                         }
  response_models      = {}
}

resource "aws_api_gateway_model" "channels_channel_patch_model" {
  rest_api_id  = var.api_id
  name         = "channelsdomainnamepatch"
  description  = "A JSON schema for POST /channels/{channel_type_and_account_id}"
  content_type = "application/json"
  schema       = file("${path.module}/request_schemas/channel_patch.json")
}

