# Elastic Stack on k8s/GKE

This project is currently in a MVP (Minimum Viable Product) status. So the entire process may invovle some manual setups (find & replace in a text editor). Once you familiar with the sturcture, you will find it's extremely easy. I am not sure if [Helm](https://helm.sh/) can achieve the flexiblity for this kind of data layer products. Let's start with simplicity anyway.

## Prerequisites

Suppose you already have access to Google Cloud Platform with proper permissions. We will use [Official ECK](https://www.elastic.co/guide/en/cloud-on-k8s/1.0/k8s-quickstart.html#k8s-deploy-eck) operator with [Official Dockers](https://www.docker.elastic.co) & [source repo](https://github.com/elastic/dockerfiles). They are all open source and free, especially the operator can handle the Elasticsearch nodes migration is a pro-way and lot more. 

Once you checked out this repo, make sure you stay in this folder as your working directory, `local_services/k8s/gke/elastic`

In case you do **not** have `gcloud` installed, you can run `./bin/gcloud install` to get it. Run `./bin/gcloud` for other usages, but importantly, make sure you have `kubectl` properly installed, or you can run `./bin/gcloud kubectl` to have it setted up.

Now you are good to go!

## How to deploy

### Setup file repository & snapshots

#### GKE: GCP Service Account file `gcs.client.default.credentials_file`

Name the file `gcs.client.default.credentials_file` and put it in `conf` dir before you `./bin/gke.sh create`

For GCS (Google Cloud Storage)

```
PUT /_snapshot/my_gcs_repository
{
    "type": "gcs",
        "settings": {
        "bucket": "my_bucket",
        "client": "default"
    }
}
```

Test snapshot

```
PUT /_snapshot/my_gcs_repository/test-snapshot
```

## Kibana

### Connect an Elasticsearch somewhere else

```
kubectl create secret generic kibana-elasticsearch-credentials --from-literal=elasticsearch.password=$PASSWORD
```

```
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: kbn
  spec:
    version: 7.6.2
    count: 1
    config:
      elasticsearch.hosts:
        - https://elasticsearch.example.com:9200
      elasticsearch.username: elastic
    secureSettings:
      - secretName: kibana-elasticsearch-credentials
```

or the Elasticsearch cluster is using a slef-signed certificate, create a k8s secret containing the CA certificate and mount to the Kibana container as follows

```
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: kbn
spec:
  version: 7.6.2
  count: 1
  config:
    elasticsearch.hosts:
      - https://elasticsearch-sample-es-http:9200
    elasticsearch.username: elastic
    elasticsearch.ssl.certificateAuthorities: /etc/certs/ca.crt
  secureSettings:
    - secretName: kibana-elasticsearch-credentials
  podTemplate:
    spec:
      volumes:
        - name: elasticsearch-certs
          secret:
            secretName: elasticsearch-certs-secret
      containers:
        - name: kibana
          volumeMounts:
            - name: elasticsearch-certs
              mountPath: /etc/certs
              readOnly: true
```

## APM Server

(TBD)

## Advanced topics

### Storage

### Elasticsearch nodes topology

### Ingress

### Miscs
