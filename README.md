# Terraform Remote State

This system consists of two terraform modules. One is an SQS queue and the other is a lambda that puts things on the SQS queue. The queue is created and the url and other needed attributes are dynamically injected into the lambda.

This also supports a production and staging environment, which are in separate accounts. They are assumed to be in the same region, but that is just to make things easier. It is assumed that the user running terraform has appropriate permissions and the following entries in their ~/.aws/credentials file.

```
[trsstaging]
aws_access_key_id = <key>
aws_secret_access_key = <secret>

[trsproduction]
aws_access_key_id =  <key>
aws_secret_access_key = <secret>
```

## DEPLOYING

If you want to deploy to staging: 

* run git clone of this repo: `git clone git@github.com:mooreds/terraform-remote-state-example.git`
* Set up terraform with an s3 backend provider (more here: https://www.terraform.io/docs/backends/types/s3.html ). 
* In the `sqs` directory, run `terraform init` and then `terraform apply`
* In the `lambda` directory, run `terraform init` and then `terraform apply`

If you want to deploy to production, we need to tell Terraform to use a different backend (because we want to use a separate bucket in the production account). 

* run git clone of this repo: `git clone git@github.com:mooreds/terraform-remote-state-example.git production-terraform-remote-state-example`
* Set up terraform with an s3 backend provider (more here: https://www.terraform.io/docs/backends/types/s3.html ). 
* In the `sqs` directory, run `terraform init -backend-config="profile=trsproduction" -backend-config="bucket=mooreds-terraform-remote-state-example-production"` and then `terraform apply`
* In the `lambda` directory, run `terraform init` and then `terraform apply`

Note: do not try to switch between backend providers in the same repo. This seems simpler, but just caused issues for me.


## LAMBDA

The lambda is deployed via a file controlled in Terraform. That is just for ease of example. In the real world you'd want to have the lambda deployed via a CI/CD since it is changing far more often then 

## CAVEATS

I know that you could share the connection info of the SQS queue in easier ways, but this allows the SQS queue to be an independent managed module and would allow it to grow if there were other components that were needed for this storage system (for example, another process that groomed the queue for error messages).
