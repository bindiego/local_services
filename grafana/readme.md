## Run Grafana in Docker

[Grafana in Docker configuraiton details](https://grafana.com/docs/grafana/latest/administration/configure-docker/)

`make run` will bring Grafana up and running on port `3000`. 

Default `admin` password is `admin`.

### Install Grafana plugins

Plugins will be installed in the mounted volume so it will not disapear upon restarts or upgrades.

1. get into the running container

```
docker exec -it grafana sh
```

2. install the required plugin

```
grafana-cli plugins install doitintl-bigquery-datasource
```

3. restart the container to take effects

```
docker restart grafana
```
