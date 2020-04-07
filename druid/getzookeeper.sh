#!/bin/bash -ex

pwd=`pwd`
zk_ver=3.4.9

#curl http://www.gtlib.gatech.edu/pub/apache/zookeeper/zookeeper-${zk_ver}/zookeeper-${zk_ver}.tar.gz -o zookeeper-${zk_ver}.tar.gz
curl http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-${zk_ver}/zookeeper-${zk_ver}.tar.gz -o zookeeper-${zk_ver}.tar.gz
tar -xzf zookeeper-${zk_ver}.tar.gz
cd zookeeper-${zk_ver}
cp conf/zoo_sample.cfg conf/zoo.cfg
./bin/zkServer.sh start 

