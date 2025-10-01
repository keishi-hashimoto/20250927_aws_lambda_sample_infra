terraform {
  required_version = "~>1.11"

  required_providers {
    aws = {
      version = ">=6.0"
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {

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
  id = var.function_name
  to = aws_lambda_function.main
}


resource "aws_lambda_function" "main" {
  # ソースコードはアプリ側のリポジトリで管理するので、こちら側では無視する
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }

  role          = aws_iam_role.main.arn
  function_name = var.function_name
  filename      = ""
  handler       = "my_func.my_handler"
  runtime       = "python3.13"

  environment {
    variables = {
      # TODO: 環境 (terraform のワークスペース) ごとに指定できるようにする
      DST_BUCKET = var.dst_bucket
    }
  }
}

import {
  id = var.lambda_role_name
  to = aws_iam_role.main
}

resource "aws_iam_role" "main" {
  name               = var.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "main" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "s3_full_access" {
  name = "AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "main" {
  policy_arn = data.aws_iam_policy.main.arn
  role       = aws_iam_role.main.name
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.main.name
  policy_arn = data.aws_iam_policy.s3_full_access.arn
}

resource "aws_s3_bucket" "lambda_invoker" {
  bucket = var.invoker_bucket
}


resource "aws_lambda_permission" "main" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.lambda_invoker.arn
}

resource "aws_s3_bucket_notification" "main" {
  bucket = aws_s3_bucket.lambda_invoker.bucket
  lambda_function {
    events              = ["s3:ObjectCreated:*"]
    lambda_function_arn = aws_lambda_function.main.arn
  }
}