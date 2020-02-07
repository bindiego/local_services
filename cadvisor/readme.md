# Use Cadvisor to monitor your docker containers on the host

## Native version

Run with pre-built one without password protection

```shell
./cadv
```

check `localhost:12080` it should be up and running

## Simple password protection

### build the docker first 

```shell
./build
```

### make your auth.htpasswd

```shell
htpasswd -c -i -b auth.htpasswd <USERNAME> <PASSWORD>
```

### run it

```
./cadv_secured
```

access `localhost:12080` with <USERNAME> & <PASSWORD>
