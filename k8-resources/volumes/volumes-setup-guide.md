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
- EC2 node security group should allow outbound NFS (port 2049) to EFS security group.
- Inbound rule example:
  - Type: NFS
  - Port: 2049
  - Source: Worker node security group
- Outbound rule example:
  - Type: NFS
  - Port: 2049
  - Destination: EFS security group

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
```
Client
  │
  ▼
Normal Service (nginx-svc-normal)
  │
  ▼
StatefulSet Pods
 ├─ Pod 0: nginx-statefulset-0
 │     │
 │     ▼
 │   PVC: www-nginx-statefulset-0
 │     │
 │     ▼
 │   EFS Mount Target us-east-1a (SG: sg-0e73876bce9ca1ac8)
 │     ▲
 │     │ NFS Port 2049 allowed from Worker Node SG (sg-02d1b8ab0e2be71c5)
 ├─ Pod 1: nginx-statefulset-1
 │     │
 │     ▼
 │   PVC: www-nginx-statefulset-1
 │     │
 │     ▼
 │   EFS Mount Target us-east-1a (SG: sg-0e73876bce9ca1ac8)
 │     ▲
 │     │ NFS Port 2049 allowed from Worker Node SG (sg-02d1b8ab0e2be71c5)
 └─ Pod 2: nginx-statefulset-2
       │
       ▼
     PVC: www-nginx-statefulset-2
       │
       ▼
     EFS Mount Target us-east-1c (SG: sg-0e73876bce9ca1ac8)
       ▲
       │ NFS Port 2049 allowed from Worker Node SG (sg-02d1b8ab0e2be71c5)
```