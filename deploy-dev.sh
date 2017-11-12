#!/bin/bash

export AWS_DEFAULT_REGION="us-west-2"
aws cloudformation create-stack --stack-name accessproxy-dev --template-body file://cloudformation/us-west-2.yml --capabilities CAPABILITY_NAMED_IAM --parameters  ParameterKey=SSHKeyName,ParameterValue=roger ParameterKey=EnvType,ParameterValue=dev

sleep 60
region="us-west-2"
credstash_key_id="`aws --region $region kms list-aliases --query "Aliases[?AliasName=='alias/credstash'].TargetKeyId | [0]" --output text`"
role_arn="`aws iam get-role --role-name AccessProxy-Role --query Role.Arn --output text`"
constraints="EncryptionContextEquals={app=accessproxy}"

aws kms create-grant --key-id $credstash_key_id --grantee-principal $role_arn --operations "Decrypt" --constraints $constraints --name accessproxy
