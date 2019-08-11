terraform apply -var aws_profile=trsproduction -var terraform_bucket="mooreds-terraform-remote-state-example-production" -var env_indicator="production" -var lambda_memory_size=256
