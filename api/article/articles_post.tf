module "articles_post_api" {
  source  = "git@github.com:ada-powerful/tf-basic-modules.git//private_api"
  api_id               = var.api_id
  api_resource_id      = "${aws_api_gateway_resource.articles.id}"
  http_method          = "POST"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = "${var.authorizer_id}"
  lambda_function_arn  = var.lambda_function_arn
  request_parameters   = {
                           "method.request.header.Authorization"  = true
                         }
  request_validator_id = var.request_validator_id
  request_models       = {
                           "application/json" = aws_api_gateway_model.articles_post_model.name
                         }
  response_models      = {
                           "application/json" = aws_api_gateway_model.articles_post_response_model.name
                         }
}

resource "aws_api_gateway_model" "articles_post_model" {
  rest_api_id  = var.api_id
  name         = "articlespost"
  description  = "A JSON schema for POST /articles"
  content_type = "application/json"
  schema       = file("${path.module}/request_schemas/articles_post.json")
}

resource "aws_api_gateway_model" "articles_post_response_model" {
  rest_api_id  = var.api_id
  name         = "articlespostresponse"
  description  = "A JSON schema for POST /articles response"
  content_type = "application/json"
  schema       = file("${path.module}/response_schemas/articles_post.json")
}

