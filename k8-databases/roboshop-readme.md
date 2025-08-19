# Roboshop Kubernetes Database Manifests - Simple Guide

This folder contains all the Kubernetes YAML files needed to deploy databases for the Roboshop project.

## What is inside?
- Each subfolder is for a different microservice database (MongoDB, MySQL, Redis, RabbitMQ, etc.)
- Every database folder has a `manifest.yml` file with all the Kubernetes resources needed for that database.
- There is also a `namespace.yml` file to create the `roboshop` namespace.
- The `EBS-SC.yml` file is for setting up the EBS StorageClass (used for dynamic storage).

## How to use these files?
1. **Create the namespace first:**
   ```bash
   kubectl apply -f namespace.yml
   ```
   > This command creates the `roboshop` namespace in your cluster. All resources will be grouped under this namespace.
2. **Set up the StorageClass (for EBS volumes):**
   ```bash
   kubectl apply -f EBS-SC.yml
   ```
   > This command sets up the EBS StorageClass for dynamic storage provisioning.
3. **Deploy each database:**
   - Go into each database folder (e.g., `mongodb`, `mysql`, `redis`, `rabbitmq`)
   - Apply the manifest:
     ```bash
     kubectl apply -f manifest.yml
     ```
     > This command creates all resources (StatefulSet, Service, PVC, etc.) for that database.
4. **Check resources after deploying:**
   - See all pods:
     ```bash
     kubectl get pods -n roboshop
     ```
     > Shows all running pods in the `roboshop` namespace.
   - See all services:
     ```bash
     kubectl get svc -n roboshop
     ```
     > Shows all services (internal and headless) in the namespace.
   - See all PVCs (PersistentVolumeClaims):
     ```bash
     kubectl get pvc -n roboshop
     ```
     > Shows all storage claims for your databases.
   - See all PVs (PersistentVolumes):
     ```bash
     kubectl get pv
     ```
     > Shows all actual storage volumes in the cluster.
   - See all StorageClasses:
     ```bash
     kubectl get sc
     ```
     > Shows available storage classes (like EBS).
   - Describe any resource for details:
     ```bash
     kubectl describe pod <pod-name> -n roboshop
     kubectl describe svc <service-name> -n roboshop
     kubectl describe pvc <pvc-name> -n roboshop
     kubectl describe pv <pv-name>
     kubectl describe sc <storageclass-name>
     ```
     > These commands show detailed info, events, and troubleshooting for each resource.
   - Check logs for a pod:
     ```bash
     kubectl logs <pod-name> -n roboshop
     ```
     > Shows the application logs for a specific pod.
   - Test DNS resolution (service name to IP):
     ```bash
     kubectl run -it busybox --image=busybox:1.28 --restart=Never -- sh
     nslookup mongodb
     nslookup mysql
     exit
     ```
     > This starts a test pod and lets you check if service names resolve to IPs inside the cluster.

## What does each manifest do?
- **Creates a StatefulSet** (for databases that need persistent storage)
- **Creates Services** (for internal and headless access)
- **Creates PVCs** (PersistentVolumeClaims for storage)
- **Creates Secrets/ConfigMaps** (for passwords and environment variables)

## Simple Points
- All resources are in the `roboshop` namespace for easy management.
- Each database is isolated in its own folder and manifest.
- Storage is handled using EBS volumes (dynamic provisioning).
- You can check logs and connectivity using standard kubectl commands.
- Delete resources with `kubectl delete -f manifest.yml` if needed.

---
This guide helps you quickly deploy and manage all Roboshop databases on Kubernetes. Use this as a reference for setup and troubleshooting.
```
EBS
 ├─ Static Provisioning
 │    1. Install EBS CSI driver
 │    2. Give EC2 access via role + EBSCSIDriverPolicy
 │    3. Create EBS volume in same AZ as EC2
 │    4. Create PV
 │    5. Create PVC
 │    6. Create Pod (use nodeSelector)
 │
 └─ Dynamic Provisioning
      1. Create StorageClass for EBS
      2. Create PVC pointing to StorageClass
      3. Pod claims storage automatically
      4. Pod uses PV created dynamically

EFS
 ├─ Static Provisioning
 │    1. Install EFS CSI driver
 │    2. Give nodes permission via EFSCSIDriverPolicy
 │    3. Create EFS volume
 │    4. Allow port 2049 in EFS SG from EC2 SG and EFS SG also
 │    5. Create PV
 │    6. Create PVC
 │    7. Mount to Pod
 │
 └─ Dynamic Provisioning
      1. Create StorageClass for EFS
      2. Create PVC pointing to StorageClass
      3. Pod claims storage automatically
      4. Pod mounts storage
```