terraform {
  required_version = "~> 0.12"

  backend "s3" {
    bucket         = "mooreds-terraform-remote-state-example-staging"
    key            = "lambda/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "terraform-remote-state-locks"
    profile        = "trsstaging"
    region         = "us-east-2"
  }
}

provider "aws" {
  version = "~> 2.13"
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

provider "template" {
  version = "~> 2.0"
}

variable "aws_profile" {
  default     = "trsstaging"
  description = "AWS profile name, as set in ~/.aws/credentials"
}

variable "aws_region" {
  type        = "string"
  default     = "us-east-2"
  description = "AWS region in which to create resources"
}

variable "env_indicator" {
  type        = "string"
  default     = "staging"
  description = "What environment are we in?"
}

variable "terraform_bucket" {
  default     = "mooreds-terraform-remote-state-example-staging"
  description = "Name of bucket that holds remote state"
}

