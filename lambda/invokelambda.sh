#!bin/sh

# assumes you have aws cli installed and that you are using the staging profile
aws --region us-east-2 --profile trsstaging lambda invoke  --function-name trslambda /dev/stdout
