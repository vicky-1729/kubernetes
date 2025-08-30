# Kubernetes Service Account with AWS IAM Integration

This directory contains examples and configurations for using Kubernetes ServiceAccounts with AWS IAM roles to securely access AWS services without embedding credentials in your application.

## Files in this Directory

- **sa-create.yaml**: ServiceAccount definition with IAM role annotation
- **serviceAccount.yaml**: Contains Role, RoleBinding, and basic Pod using the ServiceAccount
- **iam-policy.json**: AWS IAM policy granting access to Secrets Manager
- **setup-sa.sh**: Script to set up OIDC provider, IAM policy, and ServiceAccount
- **secret-test-pod.yaml**: Example Pod that retrieves a secret from AWS Secrets Manager

## Setup Instructions

1. Make sure you have the following tools installed:
   - AWS CLI
   - kubectl
   - eksctl

2. Run the setup script:
   ```bash
   chmod +x setup-sa.sh
   ./setup-sa.sh
   ```

3. Apply the pod configuration to test access:
   ```bash
   kubectl apply -f secret-test-pod.yaml
   ```

4. Check the pod logs to confirm secret retrieval:
   ```bash
   kubectl logs -n roboshop secret-test-pod
   ```

## How It Works

1. The OIDC provider establishes trust between your EKS cluster and AWS IAM
2. The IAM policy defines what AWS resources can be accessed
3. The ServiceAccount is linked to the IAM role through annotations
4. Pods using this ServiceAccount automatically receive AWS credentials
5. The AWS SDK in the pod can use these credentials without any configuration

## Security Benefits

- No AWS access keys stored in pod or ConfigMaps
- Fine-grained access control for AWS resources
- Automatic credential rotation
- Audit trail through AWS CloudTrail
