#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0b6068446e9d68cda"
Instance=("mongodb" "user" "cart" "catalogue" "redis" "mysql" "shipping" "rabbitmq" "payment" "dispatch" "frontend")
ZONE_ID="Z0488471JVN0WTD7CBXR"
DOMAIN_NAME="84dev.store"

for instance in ${Instance[@]}

do
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --security-group-ids $SG_ID\
    --query "Instances[0].InstanceId" \
    --output text)
if [ $instance != "frontend" ]
then
  IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query "Instances[*].PrivateIpAddress" \
  --output text)
else
  IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query "Instances[*].PublicIpAddress" \
  --output text)
fi
echo "$instance address is : $IP"
done




   