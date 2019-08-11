resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# from https://amido.com/blog/terraform-does-not-need-your-code-to-provision-a-lambda-function/
data "archive_file" "lambda" {
  type          = "zip"
  output_path   = "${path.module}/function_payload.zip"
  source_file   = "${path.module}/files/lambda.rb" 
}

variable "lambda_function_name" {
  default     = "trslambda"
  description = "Lambda function name"
}


resource "aws_lambda_function" "mylambda" {
  filename      = "${data.archive_file.lambda.output_path}"
  function_name = "${var.lambda_function_name}"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "lambda.handler"

  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"

  runtime = "ruby2.5"

  tags = {
    Environment = "${var.env_indicator}"
  } 

  environment {
    variables = {
      foo = "bar"
    }
  }
  depends_on    = ["aws_iam_role_policy_attachment.lambda_logs", "aws_cloudwatch_log_group.example"]
}
