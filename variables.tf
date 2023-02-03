variable "user_pool_provider_arns" {
  type    = string
  default = "arn:aws:cognito-idp:us-west-2:146525178697:userpool/us-west-2_wudfuSIqf"
}

variable "ddb_topics_table_stream_arn" {
  type    = string
  default = "arn:aws:dynamodb:us-west-2:146525178697:table/Topics/stream/2023-01-19T17:29:43.416"
}

