# A very simple nginx deployment

## kubectl commands documentation
https://kubernetes.io/docs/user-guide/kubectl/

## Deployment details

```
kubectl describe deployments
```

### Pod details

```
kubectl describe <pod name>
```

## Update the deployment

### Update the deployment yaml file then type

```
kubectl apply -f <file localtion>
```

### Update

```
kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1
```

Alternatively

```
kubectl edit deployment/nginx-deployment
```

### check the rollout status

```
kubectl rollout status deployment/nginx-deployment
```

### after the rollout succeed, check the deployment

```
kubectl get deployments
```

### check the deployment updated the pods by creating new replica set

```
kubectl get rs
```

### check the new pods
```
kubectl get pods
```

## Rollout hisotry and roll back

### Check rollout history

```
kubectl rollout history deployment/nginx-deployment
```

to see the details of a revision

```
kubectl rollout history deployment/nginx-deployment --revision=2
```

### Rolling back to a previous revision

```
kubectl rollout undo deployment/nginx-deployment
```

### Rolling back to a specific revision

```
kubectl rollout undo deployment/nginx-deployment --to-revision=2
```

## Scaling a deployment

### Horizontal pod scaling

```
kubectl scale deployment nginx-deployment --replicas=10
```

### Autoscaling
https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/

```
kubectl autoscale deployment nginx-deployment --min=10 --max=15 --cpu-percent=80
```
