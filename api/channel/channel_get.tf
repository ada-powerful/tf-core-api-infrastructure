module "channel_get_api" {
  source  = "git@github.com:ada-powerful/tf-basic-modules.git//private_api"
  api_id               = var.api_id
  api_resource_id      = "${aws_api_gateway_resource.channel.id}"
  http_method          = "GET"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = "${var.authorizer_id}"
  lambda_function_arn  = var.lambda_function_arn
  request_validator_id = var.request_validator_id
  request_parameters   = {
                           "method.request.header.Authorization" = true
                         }
  request_models       = {}
  response_models      = {
                           "application/json" = aws_api_gateway_model.channel_get_response_model.name
                         }
}

resource "aws_api_gateway_model" "channel_get_response_model" {
  rest_api_id  = var.api_id
  name         = "channelgetresponse"
  description  = "A JSON schema for GET /channel/{channel_type_and_account_id} response"
  content_type = "application/json"
  schema       = file("${path.module}/response_schemas/channel_get.json")
}

