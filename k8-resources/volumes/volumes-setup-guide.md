# Kubernetes Volumes: Setup & Common Checks

## Required Installations

### EBS CSI Driver
```
kubectl kustomize "https://github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/ecr/?ref=release-1.23" > ebs-driver.yaml
kubectl apply -f ebs-driver.yaml
```

### EFS CSI Driver
```
kubectl kustomize "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/ecr/?ref=release-2.1" > efs-driver.yaml
kubectl apply -f efs-driver.yaml
```

## Common AWS Settings to Check

### 1. Security Groups
- EFS/EBS security group must allow inbound NFS (port 2049 for EFS) from worker node security group.
- Inbound rule example:
  - Type: NFS
  - Port: 2049
  - Source: Worker node security group

### 2. Subnet & VPC
- EFS/EBS and worker nodes must be in the same VPC.
- EFS must have mount targets in subnets reachable by nodes.

### 3. IAM Role
- Worker node IAM role must have permissions for EFS/EBS CSI driver.

### 4. Network ACLs/Firewalls
- No NACLs or firewalls should block port 2049 (EFS) or required EBS ports.

### 5. StorageClass
- Use correct StorageClass for dynamic provisioning (e.g., `efs-sc` for EFS, `ebs-sc` for EBS).

### 6. PersistentVolume & PersistentVolumeClaim
- Ensure PVC matches PV (accessModes, storageClassName, etc.).

## Troubleshooting
- Check pod events: `kubectl describe pod <pod-name>`
- Check CSI driver logs:
  - `kubectl -n kube-system logs -l app=efs-csi-controller`
  - `kubectl -n kube-system logs -l app=ebs-csi-controller`
- Check AWS Console for EFS/EBS status and mount targets.

## Summary
- Install CSI drivers
- Configure AWS networking and security
- Use correct StorageClass and PVC/PV mapping
- Check IAM, network, and logs for troubleshooting
