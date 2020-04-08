## Preface

The code here is dedicated for GKE (Google managed k8s on GCP). But if you could easily port to your on-prem k8s environment without too much work.

代码主要是针对GKE（谷歌托管k8s）的，少做修改就可以改为本地k8s集群部署。主要是Docker容器构建推送的registry和k8s ymal里镜像的位置。其他都一样，有问题欢迎大家及时反馈。

## Deploy Load Testing tool Locust on k8s 

主要目的是在GEK（k8s）上快速部署一个Locust压测工具。

### Prepare your GCP project key environment

```
PROJECT=$(gcloud config get-value project)
REGION=asia-east1
ZONE=${REGION}-b
CLUSTER=gke-load-test
TARGET=${PROJECT}.appspot.com # replace this with your application endpoint
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE
```

### (optional) som services should be enabled to use the code

```
gcloud services enable \
    cloudbuild.googleapis.com \
    compute.googleapis.com \
    container.googleapis.com \
    containeranalysis.googleapis.com \
    containerregistry.googleapis.com 
```

### Create a GKE cluster to host the Locust service

```
gcloud container clusters create $CLUSTER \
    --zone $ZONE \
    --scopes "https://www.googleapis.com/auth/cloud-platform" \
    --num-nodes "3" \
    --enable-autoscaling --min-nodes "3" \
    --max-nodes "10" \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing

gcloud container clusters get-credentials $CLUSTER \
    --zone $ZONE \
    --project $PROJECT
```

### Build the Locust docker image

You have to update the `tasks.py` for your testing plan. Also, you may need to build different images for different testing workloads.

##### Caveats

For `$PROJECT` has a ':' charactor or say organization name, you need to replace ':' with '/'. For example

abc.com:my-project => abc.com/my-project

```
gcloud builds submit --tag gcr.io/$PROJECT/locust-tasks:latest docker-image/.
```

### Update the k8s deployments according to your specific load test job

```
sed -i -e "s/\[TARGET_HOST\]/$TARGET/g" kubernetes-config/locust-master-controller.yaml
sed -i -e "s/\[TARGET_HOST\]/$TARGET/g" kubernetes-config/locust-worker-controller.yaml
sed -i -e "s/\[PROJECT_ID\]/$PROJECT/g" kubernetes-config/locust-master-controller.yaml
sed -i -e "s/\[PROJECT_ID\]/$PROJECT/g" kubernetes-config/locust-worker-controller.yaml
```

Same caveat here, after this substitutions, you need to check the image id to replace ':' with '/' accordingly.

### Deploy Locust master and worker nodes

```
kubectl apply -f kubernetes-config/locust-master-controller.yaml
kubectl apply -f kubernetes-config/locust-master-service.yaml
kubectl apply -f kubernetes-config/locust-worker-controller.yaml
```

#### Get the external ip of Locust master service

Here is the web UI that used to access Locust to start your test

```
EXTERNAL_IP=$(kubectl get svc locust-master -o yaml | grep ip | awk -F":" '{print $NF}')
```

### (optional) scales the pool of Locust worker pods

```
kubectl scale deployment/locust-worker --replicas=20
```

### (optional) Use `makefile` embeded tasks to run your tests

Check the `makefile` for details, you may need to update `kubernetes-config/locust-worker-controller.yaml` for every new test.

### Cleaning up

```
gcloud container clusters delete $CLUSTER --zone $ZONE
```
