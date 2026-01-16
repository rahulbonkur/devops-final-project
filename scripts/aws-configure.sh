#!/bin/bash
# AWS Configuration helper script

echo "========================================="
echo "AWS CLI Configuration"
echo "========================================="

read -p "Enter AWS Access Key ID: " AWS_ACCESS_KEY_ID
read -p "Enter AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
read -p "Enter AWS Region [us-east-1]: " AWS_REGION
AWS_REGION=${AWS_REGION:-us-east-1}

aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set default.region "$AWS_REGION"
aws configure set default.output json

echo ""
echo "✅ AWS CLI configured successfully!"
echo ""
echo "Verifying configuration..."
aws sts get-caller-identity
