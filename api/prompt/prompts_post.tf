module "prompts_post_api" {
  source  = "git@github.com:ada-powerful/tf-basic-modules.git//private_api"
  api_id               = var.api_id
  api_resource_id      = "${aws_api_gateway_resource.prompts.id}"
  http_method          = "POST"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = "${var.authorizer_id}"
  lambda_function_arn  = var.lambda_function_arn
  request_parameters   = {
                           "method.request.header.Authorization"  = true
                         }
  request_validator_id = var.request_validator_id
  request_models       = {
                           "application/json" = aws_api_gateway_model.prompts_post_model.name
                         }
  response_models      = {
                           "application/json" = aws_api_gateway_model.prompts_post_response_model.name
                         }
}

resource "aws_api_gateway_model" "prompts_post_model" {
  rest_api_id  = var.api_id
  name         = "promptspost"
  description  = "A JSON schema for POST /prompts"
  content_type = "application/json"
  schema       = file("${path.module}/request_schemas/prompts_post.json")
}

resource "aws_api_gateway_model" "prompts_post_response_model" {
  rest_api_id  = var.api_id
  name         = "promptspostresponse"
  description  = "A JSON schema for POST /prompts response"
  content_type = "application/json"
  schema       = file("${path.module}/response_schemas/prompts_post.json")
}
