# Kubernetes Commands Reference for RoboShop

This document provides a comprehensive list of Kubernetes commands for managing the RoboShop application.

## Managing the Entire Application

### Deploy Everything

```bash
# Create namespace
kubectl apply -f 01.namespace.yml

# Set default namespace
kubectl config set-context --current --namespace=roboshop

# Deploy databases
kubectl apply -f mongodb/manifest.yml
kubectl apply -f redis/manifest.yml
kubectl apply -f mysql/manifest.yml
kubectl apply -f rabbitmq/manifest.yml

# Deploy services
kubectl apply -f catalogue/manifest.yml
kubectl apply -f user/manifest.yml
kubectl apply -f cart/manifest.yml
kubectl apply -f shipping/manifest.yml
kubectl apply -f payment/manifest.yml

# Deploy frontend
kubectl apply -f Frontend/manifest.yml

# Deploy debug container
kubectl apply -f debug/manifest.yml
```

### Check Status of All Components

```bash
# Get all resources with label project=roboshop
kubectl get all -l project=roboshop -n roboshop

# Check all pods
kubectl get pods -n roboshop

# Check all services
kubectl get svc -n roboshop

# Check all deployments
kubectl get deployments -n roboshop

# Check all configmaps
kubectl get configmaps -n roboshop

# Check all secrets
kubectl get secrets -n roboshop
```

### Delete All RoboShop Kubernetes Resources

```bash
# 1. Delete entire namespace (recommended)
kubectl delete namespace roboshop

# 2. Delete all resources by label (if label 'project=roboshop' used)
kubectl delete all -l project=roboshop -n roboshop
kubectl delete configmaps,secrets -l project=roboshop -n roboshop

# 3. Delete everything inside namespace but keep namespace itself
kubectl delete all --all -n roboshop
kubectl delete configmaps --all -n roboshop
kubectl delete secrets --all -n roboshop

# 4. Delete specific resource types individually
kubectl delete pods --all -n roboshop
kubectl delete svc --all -n roboshop
kubectl delete deployments --all -n roboshop
```

## Managing Individual Components

### MongoDB Commands

```bash
# Apply MongoDB deployment and service
kubectl apply -f mongodb/manifest.yml

# Check MongoDB pods
kubectl get pods -n roboshop -l component=mongodb

# Check MongoDB service
kubectl get svc -n roboshop -l component=mongodb

# Get logs from MongoDB pod (replace <pod-name> with actual pod name)
kubectl logs <pod-name> -n roboshop

# Exec into MongoDB pod 
kubectl exec -it $(kubectl get pods -l component=mongodb -n roboshop -o jsonpath='{.items[0].metadata.name}') -n roboshop -- bash
```

### Catalogue Commands

```bash
# 1. Apply deployment and service manifests
kubectl apply -f catalogue/manifest.yml

# 2. Check pods and services in roboshop namespace
kubectl get pods -n roboshop -l component=catalogue
kubectl get svc -n roboshop -l component=catalogue

# 3. Get logs from catalogue pod
kubectl logs -n roboshop -l component=catalogue

# 4. Exec into catalogue pod (replace <pod-name> with actual pod name)
kubectl exec -it <pod-name> -n roboshop -- /bin/sh

# 5. Restart catalogue deployment (rolling restart)
kubectl rollout restart deployment/catalogue -n roboshop

# 6. Check rollout status
kubectl rollout status deployment/catalogue -n roboshop

# 7. Rollback deployment to previous revision if needed
kubectl rollout undo deployment/catalogue -n roboshop

# 8. Delete catalogue deployment and service
kubectl delete deployment catalogue -n roboshop
kubectl delete svc catalogue -n roboshop
```

### User Commands

```bash
# Apply User deployment and service
kubectl apply -f user/manifest.yml

# Check User pods
kubectl get pods -n roboshop -l component=user

# Check User service
kubectl get svc -n roboshop -l component=user

# Get logs from User pod
kubectl logs -n roboshop -l component=user

# Restart User deployment
kubectl rollout restart deployment/user -n roboshop
```

### Cart Commands

```bash
# Apply Cart deployment and service
kubectl apply -f cart/manifest.yml

# Check Cart pods
kubectl get pods -n roboshop -l component=cart

# Check Cart service
kubectl get svc -n roboshop -l component=cart

# Get logs from Cart pod
kubectl logs -n roboshop -l component=cart

# Restart Cart deployment
kubectl rollout restart deployment/cart -n roboshop
```

### Frontend Commands

```bash
# Apply Frontend deployment and service
kubectl apply -f Frontend/manifest.yml

# Check Frontend pods
kubectl get pods -n roboshop -l component=frontend

# Check Frontend service
kubectl get svc -n roboshop -l component=frontend

# Get logs from Frontend pod
kubectl logs -n roboshop -l component=frontend

# Port-forward Frontend service to access the application
kubectl port-forward svc/frontend -n roboshop 8080:80
```

## Debugging Commands

### Using the Debug Container

```bash
# Deploy debug pod
kubectl apply -f debug/manifest.yml

# Access debug pod
kubectl exec -it roboshop-commands -- bash

# Test service connectivity from debug pod
ping mongodb
telnet mongodb 27017
curl catalogue:8080/health
```

### General Troubleshooting

```bash
# Get events in the namespace
kubectl get events -n roboshop --sort-by=.metadata.creationTimestamp

# Describe pod for detailed information (replace <pod-name> with actual pod name)
kubectl describe pod <pod-name> -n roboshop

# Check endpoints for a service
kubectl get endpoints <service-name> -n roboshop

# Check pod logs with timestamp
kubectl logs <pod-name> -n roboshop --timestamps

# Check previous container logs (if container restarted)
kubectl logs <pod-name> -n roboshop --previous

# Watch pod status in real time
kubectl get pods -n roboshop -w

# Check ConfigMap content
kubectl get configmap <configmap-name> -n roboshop -o yaml

# Edit resources on the fly (not recommended for production)
kubectl edit deployment/<deployment-name> -n roboshop
```

## Advanced Commands

### Scaling Deployments

```bash
# Scale a deployment to desired number of replicas
kubectl scale deployment/<deployment-name> --replicas=3 -n roboshop
```

### Resource Management

```bash
# Get resource usage of pods
kubectl top pods -n roboshop

# Get resource usage of nodes
kubectl top nodes
```

### Using Labels and Selectors

```bash
# Get all pods with specific label
kubectl get pods -l tier=app -n roboshop

# Get all resources with specific label
kubectl get all -l tier=database -n roboshop
```

## Cleanup

```bash
# Delete entire namespace when done
kubectl delete namespace roboshop
```
