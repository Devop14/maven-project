terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.default_tags
  }
}

variable "aws_region" {
  description = "AWS region for the environment."
  type        = string
}

variable "default_tags" {
  description = "Tags applied to resources created by the root configuration."
  type        = map(string)
  default     = {}
}
