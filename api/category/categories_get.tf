module "categories_get_api" {
  source  = "git@github.com:ada-powerful/tf-basic-modules.git//public_api"
  api_id               = var.api_id
  api_resource_id      = "${aws_api_gateway_resource.categories.id}"
  http_method          = "GET"
  lambda_function_arn  = var.lambda_function_arn
  request_validator_id = var.request_validator_id
  request_parameters   = {
                           "method.request.querystring.search_by" = true
                           "method.request.querystring.hash"      = true
                         }
  request_models       = {}
  response_models      = {
                           "application/json" = aws_api_gateway_model.categories_get_response_model.name
                         }
}

resource "aws_api_gateway_model" "categories_get_response_model" {
  rest_api_id  = var.api_id
  name         = "categoriesgetresponse"
  description  = "A JSON schema for GET /categories response"
  content_type = "application/json"
  schema       = file("${path.module}/response_schemas/categories_get.json")
}

