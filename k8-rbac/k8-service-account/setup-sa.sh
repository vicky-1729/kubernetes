#!/bin/bash

# Variables
REGION_CODE=us-east-1
CLUSTER_NAME=roboshop-dev
ACC_ID=484907489214
POLICY_NAME=SA-AWSSecretManager-Policy
ROLE_NAME=SA-AWSSecretManager-Role

# Step 1: Setup OIDC Provider
echo "Setting up OIDC Provider..."
eksctl utils associate-iam-oidc-provider \
    --region $REGION_CODE \
    --cluster $CLUSTER_NAME \
    --approve

# Step 2: Create IAM Policy
echo "Creating IAM Policy..."
aws iam create-policy \
    --policy-name $POLICY_NAME \
    --policy-document file://iam-policy.json

# Step 3: Create Service Account with IAM Role
echo "Creating Service Account with IAM Role..."
eksctl create iamserviceaccount \
    --cluster=$CLUSTER_NAME \
    --namespace=roboshop \
    --name=roboshop-secret-reader \
    --attach-policy-arn=arn:aws:iam::$ACC_ID:policy/$POLICY_NAME \
    --override-existing-serviceaccounts \
    --region $REGION_CODE \
    --approve

echo "Setup complete! You can now apply the pod.yaml to test AWS Secrets Manager access."
