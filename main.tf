terraform {
  cloud {
    organization = "huhu_ai"
    workspaces {
      name = "core-api-infrastructure"
    }
  }

  required_version = ">= 1.1.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }
  }
}

provider "aws" {
  region = "us-west-2"
  shared_credentials_files = ["./.aws/credentials"]
}

data "aws_iam_policy_document" "lambda_ec2_inline_policy" {
  statement {
    actions   = [
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeInstances",
        "ec2:AttachNetworkInterface"
    ]
    resources = ["*"]
  }
}
