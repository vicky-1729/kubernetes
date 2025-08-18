# Kubernetes StatefulSet DB Validation - One Sheet

---

## 1. Check Resources
```bash
kubectl get pods -o wide
kubectl get svc
kubectl get pvc
kubectl get pv
kubectl get sc
```

## 2. Describe for Debugging
```bash
kubectl describe pod <pod-name>
kubectl describe pvc <pvc-name>
kubectl describe pv <pv-name>
kubectl describe svc <svc-name>
kubectl describe sc <storageclass-name>
```

## 3. DNS Resolution Test (Headless Service Check)
```bash
kubectl run -it busybox --image=busybox:1.28 --restart=Never -- sh
# Inside BusyBox pod
nslookup mongodb
nslookup mysql
exit
```

> **Tip:**
> - `nslookup` checks DNS (service name → IP).
> - Kubernetes uses internal DNS (`kube-dns`) to resolve service names.

Example output:
```
Name: mongodb
Address 1: 10.100.25.25 mongodb.roboshop.svc.cluster.local
Name: mysql
Address 1: 10.100.27.132 mysql.roboshop.svc.cluster.local
```

✅ This means:
- Service exists in namespace `roboshop`.
- DNS is working; pods can use service names instead of IPs.

Any pod in the same namespace can connect to `mysql` just by writing `mysql:3306` (no need for IP).

---

## 4. MongoDB Connectivity Test
```bash
kubectl run -it mongo-client --image=mongo:4.4 --rm --restart=Never -- bash
# Inside mongo-client
mongo --host mongodb
exit
```

## 5. MySQL Connectivity Test
```bash
kubectl run mysql-client --image=mysql:5.7 -it --rm --restart=Never -- bash
# Inside mysql-client pod
mysql -h mysql -u root -p
exit
```

## 6. Logs for Debugging
```bash
kubectl logs <mongodb-pod-name>
kubectl logs <mysql-pod-name>
```

---

> This single sheet covers:
> - Pod, PVC, PV, Service, StorageClass checks
> - Descriptions for troubleshooting
> - DNS testing with BusyBox
> - DB connectivity checks (Mongo + MySQL)
> - Logs


# Kubernetes Stateful Application (MongoDB + MySQL) - Commands Cheat Sheet

```sh
# -----------------------------------
# 1. Deploy Stateful Applications
# -----------------------------------
kubectl apply -f mongodb.yaml
kubectl apply -f mysql.yaml

# -----------------------------------
# 2. Check Pods, Services, PVC, PV
# -----------------------------------
kubectl get pods -n roboshop
kubectl get svc -n roboshop
kubectl get pvc -n roboshop
kubectl get pv

# Describe in detail if needed
kubectl describe pvc mongodb-data-mongodb-0 -n roboshop
kubectl describe svc mongodb -n roboshop
kubectl describe svc mysql -n roboshop

# -----------------------------------
# 3. DNS Resolution (inside BusyBox Pod)
# -----------------------------------
kubectl run -it busybox --image=busybox:1.28 --restart=Never -- sh

# Inside BusyBox
nslookup mongodb
nslookup mysql

# -----------------------------------
# 4. Connect to MongoDB from BusyBox
# -----------------------------------
mongo --host mongodb

# -----------------------------------
# 5. Cleanup (if needed)
# -----------------------------------
kubectl delete -f mongodb.yaml
kubectl delete -f mysql.yaml
kubectl delete pvc --all -n roboshop
kubectl delete pv --all
kubectl delete pod busybox
