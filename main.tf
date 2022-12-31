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
