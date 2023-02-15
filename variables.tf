variable "user_pool_provider_arns" {
  type    = string
  default = "arn:aws:cognito-idp:us-west-2:146525178697:userpool/us-west-2_wudfuSIqf"
}

variable "ddb_topics_table_stream_arn" {
  type    = string
  default = "arn:aws:dynamodb:us-west-2:146525178697:table/Topics/stream/2023-01-19T17:29:43.416"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The subnet Ids."
  default     = ["subnet-0a604f816f19d155c", "subnet-08a06ca6aabafcab5", "subnet-080e13f078f9cb41d"]
}

variable "security_group_ids" {
  type        = list(string)
  description = "The sg Ids."
  default     = ["sg-01d5c834de60cf2f5"]
}

variable "dax_layer_arn" {
  type        = string
  default       = "arn:aws:lambda:us-west-2:146525178697:layer:dax:1"
  description = "The arn of the dax layer."
}

variable "basic_basic_layer_arn" {
  type        = string
  default       = "arn:aws:lambda:us-west-2:146525178697:layer:basic_dao:13"
  description = "The arn of the basic dao layer."
}

variable "dax_cluster_arn" {
  type        = string
  default       = "arn:aws:dax:us-west-2:146525178697:cache/huhuai-dax"
  description = "The arn of the dax cluster."
}

