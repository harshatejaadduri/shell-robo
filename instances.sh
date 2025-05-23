#!/bin/bash

AMI_ID= "ami-09c813fb71547fc4f"
SG_ID= "sg-0b6068446e9d68cda"
Instance= ("mongodb" "user" "cart" "catalogue" "redis" "mysql" "shipping" "rabbitmq" "payment" "dispatch" "frontend")
ZONE_ID= "Z0488471JVN0WTD7CBXR"
DOMAIN_NAME= "84dev.store"

for instance in ${Instance[@]}

do
aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --instance-type $instance \
    --security-groups $SG_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=<test>}]' \
   
done