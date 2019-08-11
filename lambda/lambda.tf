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
      sqs_url = "${data.terraform_remote_state.sqs.outputs.queue_url}"
    }
  }
  depends_on    = ["aws_iam_role_policy_attachment.lambda_logs", "aws_cloudwatch_log_group.example"]
}

data "terraform_remote_state" "sqs" {
  backend = "s3"
  config = {
    bucket = "${var.terraform_bucket}"
    key = "sqs/terraform.tfstate"
    encrypt = true
    dynamodb_table = "terraform-remote-state-locks"
    profile = "${var.aws_profile}"
    region = "us-east-2"
  }
}

resource "aws_iam_policy" "lambda_sqs_access" {
  name = "lambda_sqs_access"
  path = "/"
  description = "IAM policy for sqs access from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:SendMessage"
      ],
      "Resource": "${data.terraform_remote_state.sqs.outputs.queue_arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_access" {
  role = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_sqs_access.arn}"
}
