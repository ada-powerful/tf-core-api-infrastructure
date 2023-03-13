module "prompts_get_api" {
  source  = "git@github.com:ada-powerful/tf-basic-modules.git//private_api"
  api_id               = var.api_id
  api_resource_id      = "${aws_api_gateway_resource.prompts.id}"
  http_method          = "GET"
  lambda_function_arn  = var.lambda_function_arn
  authorization       = "COGNITO_USER_POOLS"
  authorizer_id       = "${var.authorizer_id}"
  request_validator_id = var.request_validator_id
  request_parameters   = {
                           "method.request.header.Authorization"  = true
                         }
  request_models       = {}
  response_models      = {
                           "application/json" = aws_api_gateway_model.prompts_get_response_model.name
                         }
}

resource "aws_api_gateway_model" "prompts_get_response_model" {
  rest_api_id  = var.api_id
  name         = "promptsgetresponse"
  description  = "A JSON schema for GET /prompts response"
  content_type = "application/json"
  schema       = file("${path.module}/response_schemas/prompts_get.json")
}
