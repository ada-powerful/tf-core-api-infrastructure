module "topics_patch_api" {
  source  = "git@github.com:ada-powerful/tf-basic-modules.git//private_api"
  api_id               = var.api_id
  api_resource_id      = "${aws_api_gateway_resource.topics.id}"
  http_method          = "PATCH"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = "${var.authorizer_id}"
  lambda_function_arn  = var.lambda_function_arn
  request_parameters   = {
                           "method.request.header.Authorization"  = true
                         }
  request_validator_id = var.request_validator_id
  request_models       = {
                           "application/json" = aws_api_gateway_model.topics_patch_model.name
                         }
  response_models      = {
                           "application/json" = aws_api_gateway_model.topics_patch_response_model.name
                         }
}

resource "aws_api_gateway_model" "topics_patch_model" {
  rest_api_id  = var.api_id
  name         = "topicspatch"
  description  = "A JSON schema for patch /topics"
  content_type = "application/json"
  schema       = file("${path.module}/request_schemas/topics_patch.json")
}

resource "aws_api_gateway_model" "topics_patch_response_model" {
  rest_api_id  = var.api_id
  name         = "topicspatchresponse"
  description  = "A JSON schema for PATCH /topics response"
  content_type = "application/json"
  schema       = file("${path.module}/response_schemas/topics_patch.json")
}

