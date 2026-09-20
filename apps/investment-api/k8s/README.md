# Kubernetes deployment

Create the database Secret outside Git. The keys must match the names used by the MySQL and API Deployments:

```bash
kubectl create secret generic mysql-credentials \
  --from-literal=MYSQL_DATABASE=investment \
  --from-literal=MYSQL_USER=investment \
  --from-literal=MYSQL_PASSWORD='<strong-password>' \
  --from-literal=MYSQL_ROOT_PASSWORD='<strong-root-password>'
```

Apply the manifests in this order:

```bash
kubectl apply -f k8s/mysql-service.yml
kubectl apply -f k8s/mysql_deployments.yml
kubectl apply -f k8s/deployment.yml
kubectl apply -f k8s/api-service.yml
```

The `api-service-clusterip.yml`, `investment-api-nodeport.yaml`, `pod.yml`, and `1` files are older alternatives. Do not apply them together with the Deployment stack because they reuse resource names or define a standalone Pod.