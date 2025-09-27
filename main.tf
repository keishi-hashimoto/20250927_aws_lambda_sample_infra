terraform {
  required_version = "~>1.11"

  required_providers {
    aws = {
      version = ">=6.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      env      = "${terraform.workspace}"
      category = "20250927_aws_lambda_sample_infra"
    }
  }
}

import {
  id = "khashimoto_20250927_sample"
  to = aws_lambda_function.main
}


resource "aws_lambda_function" "main" {
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }

  role          = data.aws_iam_role.main.arn
  function_name = "khashimoto_20250927_sample"
  filename      = ""
  handler       = "my_func.my_handler"
  runtime       = "python3.13"
}

data "aws_iam_role" "main" {
  name = var.role_name
}