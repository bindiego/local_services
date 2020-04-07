# Druid Playground

## Purpose
Run druid.io OLAP engine in docker containers

### External service variables:

#### MySQL ip and port
- %RDBIP%
- %RDBPORT%

#### Zookeeper ip and port
- %ZKIP%
- %ZKPORT%

#### memcached ip and port
- %MC_IP%
- %MC_PORT%

You will need to specify the details in docker/ptrun

### Get druid
Simply run
```shell
./getdruid.sh
```
This will download the druid archive and extract it in the current directory

### Container services:
Below are the ip addresses you will need to specify for each service. Ports are fixed.

- broker: %BROKER_IP%:48081, jmx port: 47071
- historical: %HIST_IP%:48082
- coordinator: %COORD_IP%:48083
- middleManager: %MM_IP%:48084
- overlord: %OL_IP%:48085
- realtime: %RT_IP%:48086, jmx port: 47072

You will need to specify the details in docker/ptrun

IMPORTANT: The nodes in this example do not need to be on their own individual servers. Overlord and Coordinator nodes should be co-located on the same hardware.

### Commands explanations

#### Preparation
System requirements:
- docker (tests are built upon version 1.12.5)
- GNU make (build tool)
- JRE (download extentions)

#### Zookeeper
Run zookeeper with command
```shell
make runzk
```
zookeeper will be available at local port 42181

#### MySQL
Run MySQL RDB with command
```shell
make runrdb
```
MySQL will be available at local port 43306

Afterwards, you may need to wait about 10s till the DB is fully set up. Then run command
```shell
make initrdb
```
in order to get MySQL db properly initialized

### memcached
Run memcached with command
```shell
make runmc
```
memcached will be available at local port 41211

#### Run the containers
Run command
```shell
make rundruid
```
will bring up all the basic druid services

or you can clean all the druid services by issuing the command
```shell
make cleandruid
```

## Logging
Here I haven't get it done nicely, but the following trick works well so far.

This step can be omitted and will only result the log keep appending to one file in the logs folder.

For proper log set up, please navigate to file

./druid-$DRUID_VER/bin/node.sh

For current version 0.9.2, locate line 41 which is
```shell
nohup java `cat $CONF_DIR/$nodeType/jvm.config | xargs` -cp $CONF_DIR/_common:$CONF_DIR/$nodeType:$LIB_DIR/* io.druid.cli.Main server $nodeType > $LOG_DIR/$nodeType.log &
```
and change it to
```shell
nohup java -Dlogfilename=$nodeType \
  `cat $CONF_DIR/$nodeType/jvm.config | xargs` -cp $CONF_DIR/_common:$CONF_DIR/$nodeType:$LIB_DIR/* io.druid.cli.Main server $nodeType &
```

## Production
Please consult [this document](http://druid.io/docs/latest/configuration/production-cluster.html) if you want to run containers for production. You will need to tweak the configurations in both
- druidconf folder
- docker run commands in makefile

Have fun!

## Druid http endpoints specification can be found in belowing links

- [Broker](http://druid.io/docs/0.9.2/design/broker.html)
- [Coordinator](http://druid.io/docs/0.9.2/design/coordinator.html)
- [Historical](http://druid.io/docs/0.9.2/design/historical.html)
- [Indexing Service](http://druid.io/docs/0.9.2/design/indexing-service.html)
- [Realtime](http://druid.io/docs/0.9.2/design/realtime.html)
