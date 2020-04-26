# Elastic Stack on k8s/GKE

This project is currently in a MVP (Minimum Viable Product) status. So the entire process may invovle some manual setups (find & replace in a text editor). Once you familiar with the sturcture, you will find it's extremely easy. I am not sure if [Helm](https://helm.sh/) can achieve the flexiblity for this kind of data layer products. Let's start with simplicity anyway.

## Prerequisites

Suppose you already have access to Google Cloud Platform with proper permissions. We will use [Official ECK](https://www.elastic.co/guide/en/cloud-on-k8s/1.0/k8s-quickstart.html#k8s-deploy-eck) operator with [Official Containers / Dockers](https://www.docker.elastic.co) & [Docker source repo](https://github.com/elastic/dockerfiles). They are all open source and free, especially the operator can handle the Elasticsearch nodes migration in a graceful way and lot more. 

Once you checked out this repo, make sure you stay in this folder as your working directory, `local_services/k8s/gke/elastic`

In case you do **not** have `gcloud` installed, you can run `./bin/gcloud install` to get it. Run `./bin/gcloud` for other usages, but importantly, make sure you have `kubectl` properly installed, or you can run `./bin/gcloud kubectl` to have it setted up.

Now we are good to go!

---

## Quickstart

Check the advanced topics if you would like to:

- Customize the size of your k8s/GKE nodes and pools
- Elasticsearch topology & caveats
- Use your own meaningful names for workloads/services/ingress etc.

### Preparations

#### Setup your `project_id` & targeting region to deploy

[Locate the project ID](https://support.google.com/googleapi/answer/7014113?hl=en). Open the [GCP console](https://console.cloud.google.com/), it's on the top-left corner "Project info" card by default.

Now, replace the `project_id` variable in [./bin/gke.sh](https://github.com/bindiego/local_services/blob/develop/k8s/gke/elastic/bin/gke.sh#L9) with your own project id.

For targeting region, you will need to update two files

- [./bin/gke.sh](https://github.com/bindiego/local_services/blob/develop/k8s/gke/elastic/bin/gke.sh#L7)
- [Makefile](https://github.com/bindiego/local_services/blob/develop/k8s/gke/elastic/Makefile#L1)

Change the `region` variable on your choice, `asia-east1` by default.

#### Choose a predefined Elasticsearch deployment

You can later adjust all these settings to archieve your own goal. We will discuss more in **Advanced topics**.

##### Option 1: Single node 

Run `make init_single` and you done.

##### Option 2: All role deployments, with shard allocation awareness (not forced)

| zone-a        | zone-b         |
| ------------- | -------------- |
| ES x 2        | ES x 2         |

Run `make init_allrole`

##### Option 3: Production deployments, with shard allocation awareness (not forced)

| zone-a           | zone-b           |
| ---------------- | ---------------- |
| Master x 2       | Master x 1       |
| Ingest x 1       | Ingest x 1       |
| Data x 2         | Data x 2         |
| Coordinating x 1 | Coordinating x 1 |
| ML x 1 | on any available node      |

You could even further adjust this to a single zone or 3 zones with forced shared allocation awareness, let's discuss more details in the **Advanced topics** so you could configure based on your needs.

Run `make init_prod`

#### GCP service account for GCS(Snapshots)

We use this credential for Elasticsearch cluster to manage it's snapshots. On GKE, we use [GCS](https://cloud.google.com/storage) (an object store on GCP) for that purpose.

Please consult [How to create & manage service accounts](https://cloud.google.com/iam/docs/creating-managing-service-accounts). Simply download the key, a json file, then name it `gcs.client.default.credentials_file` and put it into `conf` dir. We only need the permission to manipulate GCS, so make sure it has only the minimum permissions granted.

By now, in your *working directory*, you should be able to run `cat ./conf/gcs.client.default.credentials_file` to check the existence and the contents of the file. If you didn't do this, the auto script will later use `$GOOGLE_APPLICATION_CREDENTIALS`  environment variable to copy that file to the destination. You cannot skip this by now let's talk about how to disble in **Advanced topics** if you really have to. 

### Launch GKE/k8s cluster

Run `./bin/gke.sh create`

#### Think about the ingress by now

You can easily change whatever you want, but you'd better think about this by now since you may need to update the deployment files.

##### Option 1: GLB with forced https (**Highly recommended** because of **security**)

The only prerequisite here is you need a domain name, let's assume it is `bindiego.com`.

Let's take an overview of the connections,

Data ---https---> Global Load Balancer ---https---> Ingest nodes

Clients ---https---> Global Load Balancer ---https---> Coordinating nodes

Kibana --https---> Global Load Balancer ---https---> Kibana(s)

As you can see, we don't terminate the `https` protocol  for the LB's backends. You can certainly do by updating the yml files accordingly, let's talk about that later.

It's the time to reserve an Internet IP address for your domain. 

Run `./bin/glb.sh reserve`, this should print out the actual IP address for you. If you missed for whatever reason, you will always be able to retrieve it by `./bin/glb.sh status`

OK, time to configure your DNS

I have added 3 sub-domains for Kibana, Elasticsearch ingest & Elasticsearch client respectively. You can do that by adding 3 **A** records 

- k8na.bindiego.com
- k8es.ingest.bindiego.com
- k8es.client.bindiego.com

all pointing to the static IP address you just reserved.

Optionally, you may want to add a DNS **CAA** record to specify the authority who sign the certificate. This is super important for China mainland users, since in this *quickstart* sample we are going to use [Google managed certificate](https://cloud.google.com/load-balancing/docs/ssl-certificates/google-managed-certs?hl=hu-HU) for simplicity. Or Google signed ones will have the keyword **Google** and potentially could be blocked by the [GFW](https://en.wikipedia.org/wiki/Great_Firewall). 

- Google `CAA 0 issue "pki.goog"`
- Letsencrypt `CAA 0 issue "letsencrypt.org"`

You will need to update 2 files now,

- `./deploy/cert.yml`
- `./deploy/lb.yml`

Better do a quick `find & replace` in the text editor of your choice to have those domains configured properly according to your environment.

Once you done, it's the time to run `./bin/glb.sh cert`, wait the last step to deploy the GLB.

##### Option 2: Regional TCP LB

This one is really simple, depends on which service you would like to expose, simply uncomment the `spec.http` sections in either `./deploy/es.yml` or `./deploy/kbn.yml` or both. And you **do not** need to deploy the GLB in the end as you will do for option 1.

##### Option 3: Internal access only

(TBD)

### Deploy Elasticsearch Cluster

`./bin/es.sh deploy`

Services may take a little while (1min or 2) to in a ready status. Check it in the GCP console or by `kubectl` commands.

#### Get user *elastic* credentials

`./bin/es.sh password`

You will need this credential to login to Kibana or talking to Elasticsearch cluster. For the latest version, when interacting with Elasticsearch, you may want a [token based authentication](https://www.elastic.co/guide/en/elasticsearch/reference/master/token-authentication-services.html) rather than embeded usernname & password.

### Deploy Kibana

`./bin/kbn.sh deploy`

### Deploy the GLB for ingress

`./bin/glb.sh deploy`

After this you should be able to test your cluster, assume the domain is `bindiego.com`

1. Access Kibana via `k8na.bindiego.com` with username `elastic` and password from `./bin/es.sh password`

2. Test Elasticsearch ingest nodes

```
curl -u "elastic:<passwd>" -k "https://k8es.ingest.bindiego.com"
```

3. Test Elasticsearch coordinating nodes

```
curl -u "elastic:<passwd>" -k "https://k8es.client.bindiego.com"
```

Feel free to remove `-k` option since your certificate is managed by Google.

We done by now. Further things todo:

- Setup the file repo & snapshots to backup your data 
- Go to **Advanced topics** for more complex setups, mostly about manipulating yml files.

### Setup file repository & snapshots

Configure GCS (Google Cloud Storage) bucket

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

---

## Advanced topics

### Storage

### Elasticsearch nodes topology

### Ingress

### Miscs
