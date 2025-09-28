variable "function_name" {
  type        = string
  description = "lambda function name"
}

variable "lambda_role_name" {
  type        = string
  description = "lambda execution role name"
}

variable "invoker_bucket" {
  type        = string
  description = "Bucket name of lambda event source"
}