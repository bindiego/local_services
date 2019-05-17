### Preface

The easiest way to manage Elastic Staick

- SaaS: https://cloud.elastic.co
- On premise: https://www.elastic.co/products/ece

Or run Elastic Stack in Docker https://github.com/bindiego/docker_images/tree/master/elastic

The scripts are not perfect, if you see any errors, simply follow the instructions to get it fixed.

### Elasticsearch

Start with

```
./bin/es.sh deploy
```

Then update your local settings in the config folder, finally,

```
./bin/es.sh start
```

You should have Elasticsearch up and running.

### Kibana

Start with

```
./bin/kbn.sh deploy
```

Then update your local settings, finally,

```
./bin/kbn.sh start
```

Should bring your Kibana instance up and running.

### To increase file descriptors

#### CentOS7

file: /etc/security/limits.d/20-nproc.conf 

or maybe just file

/etc/security/limits.conf 

```
*          soft    nproc     4096
root       soft    nproc     unlimited
```

to

```
@ptmind          soft    nproc     65536
@ptmind          hard    nproc     65536
@ptmind          soft    nofile    65536
@ptmind          hard    nofile    65536
```

change 4096 to unlimited

double check 

```
sysctl -a | less
```

update

```
fs.file-max = 1614933
```

Finally, run the command

```
sudo sysctl -p; sysctl -p
```

### Use nginx as kibana proxy and force https with basic authentication
### 用nginx做Kibana代理，并且强制https和使用基本认证

**IMPORTANT: Run all commands in `elastic` folder**

#### Preparation

1. (Optional) generate self-signed certificate
```
./bin/cert-gen.sh
```

2. Creating a password file by using `htpasswd`
This file is used to authenticate a user.
```
htpasswd -c conf/nginx/.htpasswd elastic
```
replace `elastic` with your desired username, `-c` option will create the file if the file doesn't exist. You can continously create more users by taking out the `-c` but look, you do not have authorization control anyway. So I presume one user is good for most of the cases. Or consider x-pack :)

3. Update the nginx configuration file
File is located at `conf/nginx/nginx.conf`

if you have a domain name, uncomment
```
#server_name jenkins.domain.com;
```
in server 443 section, otherwise you can ignore

**Do** change the settings bellow to reflect your environment
```
proxy_pass http://10.140.0.3:5601;
proxy_redirect http://10.140.0.3:5601 https://10.140.0.3:5601;
```

#### Run nginx in docker

Simply run the following command in the elastic folder will do the trick. It runs nginx in the docker, so docker is prereq for this. Or you can actually use the conf/nginx/nginx.conf for your own nginx instance.

```
./bin/nginx
```

### AQI data 
collected from http://www.stateair.net/
