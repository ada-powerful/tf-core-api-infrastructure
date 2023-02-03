module "topic_delete_api" {
  source  = "git@github.com:ada-powerful/tf-basic-modules.git//private_api"
  api_id              = var.api_id
  api_resource_id     = "${aws_api_gateway_resource.topic.id}"
  http_method         = "DELETE"
  authorization       = "COGNITO_USER_POOLS"
  authorizer_id       = "${var.authorizer_id}"
  lambda_function_arn = var.lambda_function_arn
  request_parameters  = {
                          "method.request.header.Authorization"  = true
                        }
  request_validator_id = var.request_validator_id
  request_models      = {}
  response_models     = {}
}

