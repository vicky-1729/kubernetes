# RoboShop on Kubernetes - Simple Guide

## 1. Project Overview

RoboShop is a microservices-based e-commerce application with these components:

- **Frontend**: Web interface for users (Nginx)
- **Catalogue**: Shows product listings (NodeJS, connects to MongoDB)
- **User**: Manages user accounts (NodeJS, connects to MongoDB and Redis)
- **Cart**: Handles shopping cart (NodeJS, connects to Redis)
- **Shipping**: Processes delivery information (Java, connects to MySQL)
- **Payment**: Processes payments (Python, connects to RabbitMQ)
- **MongoDB**: Database for catalogue and user data
- **MySQL**: Database for shipping information
- **Redis**: In-memory database for cart and user sessions
- **RabbitMQ**: Message queue for payment processing

## 2. Deployment Steps

### Step 1: Set up Kubernetes environment
Make sure you have a running Kubernetes cluster and kubectl configured:

```bash
kubectl get nodes
```

### Step 2: Create namespace and set as default
```bash
# Create roboshop namespace
kubectl apply -f 01.namespace.yml

# Set as default namespace
kubectl config set-context --current --namespace=roboshop
```

### Step 3: Deploy databases
Always deploy databases first because services depend on them:

```bash
# MongoDB (for catalogue and user)
kubectl apply -f mongodb/manifest.yml

# Redis (for cart)
kubectl apply -f redis/manifest.yml

# MySQL (for shipping)
kubectl apply -f mysql/manifest.yml

# RabbitMQ (for payment)
kubectl apply -f rabbitmq/manifest.yml
```

### Step 4: Wait for databases to be ready
Check that all database pods are running properly:
```bash
kubectl get pods -l tier=database
```

### Step 5: Deploy application services
Now deploy the microservices that will use the databases:

```bash
# Catalogue service
kubectl apply -f catalogue/manifest.yml

# User service
kubectl apply -f user/manifest.yml

# Cart service
kubectl apply -f cart/manifest.yml

# Shipping service
kubectl apply -f shipping/manifest.yml

# Payment service
kubectl apply -f payment/manifest.yml
```

### Step 6: Deploy frontend
Deploy the web interface that connects to all backend services:

```bash
kubectl apply -f Frontend/manifest.yml
```

### Step 7: Deploy debug container
This container has troubleshooting tools the Alpine-based images don't include:

```bash
kubectl apply -f debug/manifest.yml
```

### Step 8: Verify everything is running
```bash
kubectl get all -l project=roboshop
```

### Step 9: Access the application
```bash
kubectl port-forward svc/frontend 8080:80
```
Then open http://localhost:8080 in your browser.

## 3. Project Structure Details

Each service is defined with these Kubernetes resources:

### MongoDB, Redis, MySQL, RabbitMQ
- **Deployment**: Running the database container
- **Service**: Making the database accessible to other services
- **Secret** (for MySQL and RabbitMQ): Storing credentials

### Catalogue, User, Cart, Shipping, Payment
- **ConfigMap**: Environment variables for database connections
- **Deployment**: Running the service container
- **Service**: Exposing APIs to other services
- **Secret** (some services): Storing sensitive credentials

### Frontend
- **ConfigMap**: Nginx configuration for routing to microservices
- **Deployment**: Running the web interface container
- **Service**: Exposing the website

### Debug Container
- Custom container with troubleshooting tools like:
  - telnet
  - net-tools
  - iputils
  - curl

## 4. Helpful Setup Tools

### Set Default Namespace
Save time by setting the namespace as default:
```bash
kubectl config set-context --current --namespace=roboshop
```

### Install Helpful Management Tools
For easier Kubernetes management:

#### kubens - For namespace switching
```bash
# Install via kubectl-krew
kubectl krew install ns

# Switch namespace
kubens roboshop
```

#### k9s - Terminal UI for Kubernetes
```bash
# Install on various platforms
brew install k9s  # Mac
choco install k9s  # Windows

# Launch the interface
k9s
```

## 5. Troubleshooting

### Using the Debug Container

Log into the debug container to test connectivity:
```bash
kubectl exec -it roboshop-commands -- bash
```

From inside the debug container, you can:
```bash
# Test database connections
ping mongodb
telnet mongodb 27017
telnet mysql 3306
telnet redis 6379
telnet rabbitmq 5672

# Test microservices
curl catalogue:8080/health
curl user:8080/health
curl cart:8080/health
curl shipping:8080/health
curl payment:8080/health

# Check DNS resolution
nslookup catalogue
nslookup user
```

### Common Issues and Solutions

1. **Pod won't start**: 
   - Check if your cluster has enough resources
   - Check node status: `kubectl get nodes`

2. **ImagePullBackOff**: 
   - Image might be misspelled or inaccessible
   - Check image repository access

3. **CrashLoopBackOff**:
   - Check logs: `kubectl logs <pod-name>`
   - Check events: `kubectl describe pod <pod-name>`

4. **Service connection failures**:
   - Verify endpoints: `kubectl get endpoints <service-name>`
   - Test connectivity from debug pod

## 6. Useful Commands

### Pod and Service Checking
```bash
# Check all resources in the project
kubectl get all -l project=roboshop

# Check specific resource types
kubectl get pods
kubectl get svc
kubectl get configmaps
kubectl get secrets

# View logs
kubectl logs deployment/frontend
```

### Restarting or Deleting
```bash
# Restart a deployment
kubectl rollout restart deployment/<name>

# Delete and recreate everything
kubectl delete namespace roboshop
kubectl apply -f 01.namespace.yml
# Then apply all manifests again
```

## 7. Cleanup
When you're done with the project, clean up:
```bash
kubectl delete namespace roboshop
```

---

## Quick Reference

1. **Setup**: Create namespace, set as default
2. **Deploy order**: Databases → Services → Frontend → Debug
3. **Verify**: Check pods, services, endpoints
4. **Debug**: Use debug container for connectivity tests
5. **Access**: Port-forward frontend to localhost

Remember: Always deploy databases first, then services that depend on them, then frontend. Use the debug container to verify connectivity between services.
