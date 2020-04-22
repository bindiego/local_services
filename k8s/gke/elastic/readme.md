## GKE setup

### Setup `sysctl -w vm.max_map_count=262144` - **Deprecated** switched to daemonset to address this issue now

*Still working if you still this way to fix nodes*

You will need to run `./bin/gke.sh fix` every time you scaled up the cluster.

Alternatively, add your [public key](https://console.cloud.google.com/compute/metadata/sshKeys) to meta, so you could use `ssh` rather than `gcloud compute ssh` @line:37 in `gke_sysctl_vmmaxmapcount.sh`

## Run Elasticsearch on k8s

[Official ECK](https://www.elastic.co/guide/en/cloud-on-k8s/1.0/k8s-quickstart.html#k8s-deploy-eck)

[yq](https://mikefarah.gitbook.io/yq/) is a nice tool for yaml templating

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
  name: kibana-sample
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
  name: kibana-sample
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
