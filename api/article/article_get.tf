module "article_get_api" {
  source  = "git@github.com:ada-powerful/tf-basic-modules.git//public_api"
  api_id               = var.api_id
  api_resource_id      = "${aws_api_gateway_resource.article.id}"
  http_method          = "GET"
  lambda_function_arn  = var.lambda_function_arn
  request_validator_id = var.request_validator_id
  request_parameters   = {}
  request_models       = {}
  response_models      = {
                           "application/json" = aws_api_gateway_model.article_get_response_model.name
                         }
}

resource "aws_api_gateway_model" "article_get_response_model" {
  rest_api_id  = var.api_id
  name         = "articlegetresponse"
  description  = "A JSON schema for GET /articles/{domain_name} response"
  content_type = "application/json"
  schema       = file("${path.module}/response_schemas/article_get.json")
}
