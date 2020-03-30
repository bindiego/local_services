### GKE GLB + NEG

#### First thing first, setup credentials

```
gcloud container clusters get-credentials "<cluster_name>" --zone "<zone>" --project "<project_id>"
```

#### Deploy the app

```
kubectl apply -f hello-dep.yml
```

##### Check the deployment

```
kubectl get deployment
```

#### Create service and annotate as NEG

```
kubectl apply -f hello-svc.yml
```

#####  Check the service

```
kubectl get service
```

#### Create GLB ingress

```
kubectl apply -f hello-ingress.yml
```

##### Check the GLB ingres, this may take a while to fully functional

```
kubectl get ingress --output yaml
```
