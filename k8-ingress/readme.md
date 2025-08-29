# Ingress Controller Setup Flow
---
## 1. OIDC Provider Setup
# Step 1: Establish trust between your EKS cluster and AWS IAM using OIDC (needed for IAM roles for service accounts)
REGION_CODE=us-east-1
CLUSTER_NAME=roboshop-dev
ACC_ID=315069654700
```
eksctl utils associate-iam-oidc-provider \
    --region $REGION_CODE \
    --cluster $CLUSTER_NAME \
    --approve
```

## 2. Download IAM Policy
# Step 2: Download the recommended IAM policy for the AWS Load Balancer Controller
```
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.4/docs/install/iam_policy.json
```

## 3. Create IAM Policy in AWS
# Step 3: Create the IAM policy in your AWS account so it can be attached to a role
```
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json
```

## 4. Create IAM Role & K8s ServiceAccount
# Step 4: Map the IAM role to a Kubernetes ServiceAccount for pod permissions
```
eksctl create iamserviceaccount \
--cluster=$CLUSTER_NAME \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::$ACC_ID:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--region $REGION_CODE \
--approve
```

## 5. Install AWS Load Balancer Controller with Helm
# Step 5: Add the EKS charts repo and install the AWS Load Balancer Controller using Helm
```
helm repo add eks https://aws.github.io/eks-charts
```

```
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=$CLUSTER_NAME --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
```

# After these steps, your Ingress Controller is ready to manage ALB and route external traffic to your pods/VMs.

eksctl utils associate-iam-oidc-provider \
    --region $REGION_CODE \
    --cluster $CLUSTER_NAME \
    --approve
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.4/docs/install/iam_policy.json
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json
eksctl create iamserviceaccount \
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=$CLUSTER_NAME --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller