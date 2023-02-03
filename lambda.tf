variable "api_version" {
  type    = string
  default = "v1.0.0"
}

module "core_api_s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  bucket = "aigc-core-rest-api-bucket"
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  
  versioning = {
    enabled = true
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_bucket_encryption" {
  bucket = module.core_api_s3.s3_bucket_id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
  
  provisioner "local-exec" {
    working_dir = "${path.module}/script/"
    command = format("./package.py %s %s",module.core_api_s3.s3_bucket_id,var.api_version)
  }
}

resource "aws_lambda_function" "channels" {
  depends_on = [
    resource.aws_s3_bucket_server_side_encryption_configuration.lambda_bucket_encryption
  ]
  function_name = "Channels"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = module.core_api_s3.s3_bucket_id
  s3_key    = format("%s/core.zip",var.api_version)

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "main.dispatch"
  runtime = "python3.9"

  role = "${aws_iam_role.lambda_channels_exec.arn}"
}

resource "aws_lambda_function" "categories" {
  depends_on = [
    resource.aws_s3_bucket_server_side_encryption_configuration.lambda_bucket_encryption
  ]
  function_name = "Categories"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = module.core_api_s3.s3_bucket_id
  s3_key    = format("%s/core.zip",var.api_version)

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "main.dispatch"
  runtime = "python3.9"

  role = "${aws_iam_role.lambda_exec.arn}"
}

resource "aws_lambda_function" "articles" {
  depends_on = [
    resource.aws_s3_bucket_server_side_encryption_configuration.lambda_bucket_encryption
  ]
  function_name = "Articles"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = module.core_api_s3.s3_bucket_id
  s3_key    = format("%s/core.zip",var.api_version)

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "main.dispatch"
  runtime = "python3.9"

  role = "${aws_iam_role.lambda_exec.arn}"
}

resource "aws_lambda_function" "topics" {
  depends_on = [
    resource.aws_s3_bucket_server_side_encryption_configuration.lambda_bucket_encryption
  ]
  function_name = "Topics"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = module.core_api_s3.s3_bucket_id
  s3_key    = format("%s/core.zip",var.api_version)

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "main.dispatch"
  runtime = "python3.9"

  role = "${aws_iam_role.lambda_topics_exec.arn}"
}

resource "aws_lambda_function" "operators" {
  depends_on = [
    resource.aws_s3_bucket_server_side_encryption_configuration.lambda_bucket_encryption
  ]
  function_name = "Operators"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = module.core_api_s3.s3_bucket_id
  s3_key    = format("%s/core.zip",var.api_version)

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "main.dispatch"
  runtime = "python3.9"

  role = "${aws_iam_role.lambda_exec.arn}"
}

resource "aws_lambda_function" "prompts" {
  depends_on = [
    resource.aws_s3_bucket_server_side_encryption_configuration.lambda_bucket_encryption
  ]
  function_name = "Prompts"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = module.core_api_s3.s3_bucket_id
  s3_key    = format("%s/core.zip",var.api_version)

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "main.dispatch"
  runtime = "python3.9"

  role = "${aws_iam_role.lambda_exec.arn}"
}

resource "aws_lambda_function" "packager" {
  depends_on = [
    resource.aws_s3_bucket_server_side_encryption_configuration.lambda_bucket_encryption
  ]
  function_name = "Packager"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = module.core_api_s3.s3_bucket_id
  s3_key    = format("%s/packager.zip",var.api_version)

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "main.handler"
  runtime = "python3.9"

  role = "${aws_iam_role.lambda_packager_exec.arn}"
}

data "aws_iam_policy_document" "lambda_core_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_core_ddb_inline_policy" {
  statement {
    actions   = [
        "dynamodb:BatchGetItem",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchWriteItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:Query",
        "dynamodb:DeleteItem"
    ]
    resources = [
        format("arn:aws:dynamodb:us-west-2:%s:table/Channels",data.aws_caller_identity.current.account_id),
        format("arn:aws:dynamodb:us-west-2:%s:table/Categories",data.aws_caller_identity.current.account_id),
        format("arn:aws:dynamodb:us-west-2:%s:table/Articles",data.aws_caller_identity.current.account_id),
        format("arn:aws:dynamodb:us-west-2:%s:table/Topics",data.aws_caller_identity.current.account_id),
        format("arn:aws:dynamodb:us-west-2:%s:table/Operators",data.aws_caller_identity.current.account_id),
        format("arn:aws:dynamodb:us-west-2:%s:table/Canvases",data.aws_caller_identity.current.account_id),
        format("arn:aws:dynamodb:us-west-2:%s:table/Watermarks",data.aws_caller_identity.current.account_id),
        format("arn:aws:dynamodb:us-west-2:%s:table/Prompts",data.aws_caller_identity.current.account_id),
        format("arn:aws:dynamodb:us-west-2:%s:table/Categories/index/*",data.aws_caller_identity.current.account_id),
        format("arn:aws:dynamodb:us-west-2:%s:table/Articles/index/*",data.aws_caller_identity.current.account_id),
        format("arn:aws:dynamodb:us-west-2:%s:table/Channels/index/*",data.aws_caller_identity.current.account_id),
        format("arn:aws:dynamodb:us-west-2:%s:table/Topics/index/*",data.aws_caller_identity.current.account_id),
        format("arn:aws:dynamodb:us-west-2:%s:table/Operators/index/*",data.aws_caller_identity.current.account_id),
        format("arn:aws:dynamodb:us-west-2:%s:table/Prompts/index/*",data.aws_caller_identity.current.account_id),
        format("arn:aws:dynamodb:us-west-2:%s:table/Canvases/index/*",data.aws_caller_identity.current.account_id),
        format("arn:aws:dynamodb:us-west-2:%s:table/Watermarks/index/*",data.aws_caller_identity.current.account_id)
    ]
  }
}

data "aws_iam_policy_document" "lambda_core_ddb_stream_inline_policy" {
  statement {
    actions   = [
        "dynamodb:GetRecords",
        "dynamodb:GetShardIterator",
        "dynamodb:DescribeStream",
        "dynamodb:ListStreams"
    ]
    resources = [
        format("arn:aws:dynamodb:us-west-2:%s:table/Topics/stream/*",data.aws_caller_identity.current.account_id)
    ]
  }
}

data "aws_iam_policy_document" "lambda_core_ddb_packager_inline_policy" {
  statement {
    actions   = [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
    ]
    resources = [
        format("arn:aws:dynamodb:us-west-2:%s:table/Topics",data.aws_caller_identity.current.account_id)
    ]
  }
}

data "aws_iam_policy_document" "lambda_core_sqs_inline_policy" {
  statement {
    actions   = [
        "sqs:SendMessageBatch",
        "sqs:SendMessage",
        "sqs:GetQueueUrl"
    ]
    resources = [
        format("arn:aws:sqs:us-west-2:%s:aigc-content-producer-queue", data.aws_caller_identity.current.account_id)
    ]
  }
}

data "aws_iam_policy_document" "lambda_invoke_inline_policy" {
  statement {
    actions   = [
        "lambda:InvokeFunction"
    ]
    resources = [
        format("arn:aws:lambda:us-west-2:%s:function:Packager", data.aws_caller_identity.current.account_id)
    ]
  }
}

data "aws_iam_policy_document" "lambda_invoke_token_func_inline_policy" {
  statement {
    actions   = [
        "lambda:InvokeFunction"
    ]
    resources = [
        format("arn:aws:lambda:us-west-2:%s:function:FBToken", data.aws_caller_identity.current.account_id)
    ]
  }
}

data "aws_iam_policy_document" "lambda_core_cw_log_stream_inline_policy" {
  statement {
    actions   = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ]
    resources = [
        format("arn:aws:logs:us-west-2:%s:*",data.aws_caller_identity.current.account_id)
    ]
  }
}

data "aws_iam_policy_document" "lambda_core_cw_log_group_inline_policy" {
  statement {
    actions   = [
        "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "lambda_core_api_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_core_assume_role_policy.json
  inline_policy {
    name   = "lambda_core_ddb_inline_policy"
    policy = data.aws_iam_policy_document.lambda_core_ddb_inline_policy.json
  }
  
  inline_policy {
    name   = "lambda_core_cw_log_stream_inline_policy"
    policy = data.aws_iam_policy_document.lambda_core_cw_log_stream_inline_policy.json
  }
  
  inline_policy {
    name   = "lambda_core_cw_log_group_inline_policy"
    policy = data.aws_iam_policy_document.lambda_core_cw_log_group_inline_policy.json
  }
}

resource "aws_iam_role" "lambda_channels_exec" {
  name               = "lambda_channels_func_exec_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_core_assume_role_policy.json
  inline_policy {
    name   = "lambda_core_ddb_inline_policy"
    policy = data.aws_iam_policy_document.lambda_core_ddb_inline_policy.json
  }
  
  inline_policy {
    name   = "lambda_invoke_token_func_inline_policy"
    policy = data.aws_iam_policy_document.lambda_invoke_token_func_inline_policy.json
  }
  
  inline_policy {
    name   = "lambda_core_cw_log_stream_inline_policy"
    policy = data.aws_iam_policy_document.lambda_core_cw_log_stream_inline_policy.json
  }
  
  inline_policy {
    name   = "lambda_core_cw_log_group_inline_policy"
    policy = data.aws_iam_policy_document.lambda_core_cw_log_group_inline_policy.json
  }
}

resource "aws_iam_role" "lambda_topics_exec" {
  name               = "lambda_topics_func_exec_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_core_assume_role_policy.json
  inline_policy {
    name   = "lambda_core_ddb_inline_policy"
    policy = data.aws_iam_policy_document.lambda_core_ddb_inline_policy.json
  }
  
  inline_policy {
    name   = "lambda_invoke_inline_policy"
    policy = data.aws_iam_policy_document.lambda_invoke_inline_policy.json
  }
  
  inline_policy {
    name   = "lambda_core_cw_log_stream_inline_policy"
    policy = data.aws_iam_policy_document.lambda_core_cw_log_stream_inline_policy.json
  }
  
  inline_policy {
    name   = "lambda_core_cw_log_group_inline_policy"
    policy = data.aws_iam_policy_document.lambda_core_cw_log_group_inline_policy.json
  }
}

resource "aws_iam_role" "lambda_packager_exec" {
  name               = "lambda_core_api_packager_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_core_assume_role_policy.json
  inline_policy {
    name   = "lambda_core_sqs_inline_policy"
    policy = data.aws_iam_policy_document.lambda_core_sqs_inline_policy.json
  }
  
  inline_policy {
    name   = "lambda_core_ddb_packager_inline_policy"
    policy = data.aws_iam_policy_document.lambda_core_ddb_packager_inline_policy.json
  }
  
  inline_policy {
    name   = "lambda_core_ddb_stream_inline_policy"
    policy = data.aws_iam_policy_document.lambda_core_ddb_stream_inline_policy.json
  }
  
  inline_policy {
    name   = "lambda_core_cw_log_stream_inline_policy"
    policy = data.aws_iam_policy_document.lambda_core_cw_log_stream_inline_policy.json
  }
  
  inline_policy {
    name   = "lambda_core_cw_log_group_inline_policy"
    policy = data.aws_iam_policy_document.lambda_core_cw_log_group_inline_policy.json
  }
}

resource "aws_lambda_event_source_mapping" "ddb_topics_table_to_packager" {
  event_source_arn  = var.ddb_topics_table_stream_arn
  function_name     = aws_lambda_function.packager.arn
  starting_position = "LATEST"
  filter_criteria {
    filter {
      pattern = jsonencode(
        {
          userIdentity = {
            principalId = [
              "dynamodb.amazonaws.com"
            ]
            type        = [
              "Service"
            ]
          }
        }
      )
    }
  }
}
