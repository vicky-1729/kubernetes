# Kubernetes Commands Reference for RoboShop

This document provides essential Kubernetes commands for managing the RoboShop application.

## Managing the Application

### Deploy and Check Status

```bash
# Set default namespace to save typing -n roboshop every time
kubectl config set-context --current --namespace=roboshop

# Check all resources with the project label
kubectl get all -l project=roboshop

# Check basic resources
kubectl get pods,svc,deployments
```

### Delete Resources

```bash
# Delete entire namespace when done
kubectl delete namespace roboshop

# Delete specific components if needed
kubectl delete -f catalogue/manifest.yml
```

## Managing Catalogue Service as an Example

```bash
# 1. Apply deployment and service manifests
kubectl apply -f catalogue/manifest.yml

# 2. Check pods and services
kubectl get pods -l component=catalogue
kubectl get svc -l component=catalogue

# 3. Get logs from catalogue pod
kubectl logs -l component=catalogue

# 4. Exec into catalogue pod (replace <pod-name> with actual pod name)
kubectl exec -it <pod-name> -- /bin/sh

# 5. Restart catalogue deployment (rolling restart)
kubectl rollout restart deployment/catalogue

# 6. Check rollout status
kubectl rollout status deployment/catalogue

# 7. Rollback deployment to previous revision if needed
kubectl rollout undo deployment/catalogue

# 8. Delete catalogue deployment and service
kubectl delete deployment catalogue
kubectl delete svc catalogue
```

## Debugging & Troubleshooting

### Using the Debug Container

```bash
# Deploy debug pod
kubectl apply -f debug/manifest.yml

# Access debug pod
kubectl exec -it roboshop-commands -- bash

# From inside the debug pod:
ping catalogue
telnet catalogue 8080
curl catalogue:8080/health
```

### General Troubleshooting

```bash
# Get events in the namespace
kubectl get events --sort-by=.metadata.creationTimestamp

# Describe pod for details
kubectl describe pod <pod-name>

# Check endpoints for a service
kubectl get endpoints catalogue

# Watch pod status in real time
kubectl get pods -w
```

## Common Tasks

```bash
# Scale a deployment
kubectl scale deployment/catalogue --replicas=3

# View resource usage
kubectl top pods

# Filter by labels
kubectl get all -l component=catalogue
kubectl get all -l tier=app
```
