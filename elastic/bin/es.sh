#!/bin/bash

# Author: Bin Wu <bin.wu@elastic.co>

PWD=`pwd`
JAVA=`which java`
VER=$(<ver)
IPADDR=$(hostname -I | cut -d ' ' -f 1)

__usage() {
    echo "Usage: elasticsearch {start|stop|status|deploy}"
}

__status() {
    PID=`ps -elf | egrep "elasticsearch" | egrep -v "es.sh|grep" | awk '{print $4}'`
    if [ -z "$PID" ]
    then
        echo "elasticsearch is not running"
    else
        echo "elasticsearch is running, pid: $PID"
    fi
}

__stop() {
    PID=`ps -elf | egrep "elasticsearch" | egrep -v "es.sh|grep" | awk '{print $4}'`
    if [ -z "$PID" ]
    then
        echo "elasticsearch is not running"
    else
        echo -n "Shutting down elasticsearch ... "

        kill -9 $PID
        if [ $? -eq 0 ]
        then
            echo "succeed."
        else
            echo "failed."
        fi
    fi
}

__deploy() {
    __stop

	sudo sysctl -w vm.max_map_count=262144
    sudo swapoff -a

    # setup directories
	[ -d $PWD/deploy ] || mkdir -p $PWD/deploy
	[ -d $PWD/data ] || mkdir -p $PWD/data
	[ -d $PWD/data/es/logs ] || mkdir -p $PWD/data/es/logs

    # download the package
	[ -f $PWD/deploy/elasticsearch.tar.gz ] || \
		curl https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$VER-linux-x86_64.tar.gz \
		--output $PWD/deploy/elasticsearch.tar.gz
	[ -d $PWD/deploy/elasticsearch ] || \
        mkdir $PWD/deploy/elasticsearch; \
		tar xzf $PWD/deploy/elasticsearch.tar.gz -C $PWD/deploy && \
        cp -af $PWD/deploy/elasticsearch-$VER/* $PWD/deploy/elasticsearch

    $PWD/deploy/elasticsearch/bin/elasticsearch-keystore create

	if [ ! -d $PWD/conf/elasticsearch ]
	then
		mkdir -p $PWD/conf/elasticsearch
		cp -a $PWD/deploy/elasticsearch/config/* $PWD/conf/elasticsearch/
        cp $PWD/conf/es.jvm.options $PWD/conf/elasticsearch/jvm.options
	fi

    echo "Security features are turned on v7.1.0 onwards, please run bin/es.passwd.sh to setup and for all other components, e.g. Kibana, Beats & APM etc."
}

__start() {
    #__deploy

    echo -n "Starting elasticsearch ... "

    ES_JAVA_OPTS="-Xms4g -Xmx4g -XX:-UseConcMarkSweepGC -XX:-UseCMSInitiatingOccupancyOnly -XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=75" \
        ES_PATH_CONF=$PWD/conf/elasticsearch \
	    $PWD/deploy/elasticsearch/bin/elasticsearch \
        -d -p $PWD/deploy/es.pid \
		-Ecluster.name=bindigo \
		-Enode.name=tiger \
		-Epath.data=$PWD/data/es \
		-Epath.logs=$PWD/data/es/logs \
		-Enetwork.host=0.0.0.0 \
		-Ediscovery.type=single-node \
        -Expack.security.enabled=true
        #-Expack.security.transport.ssl.enabled=true \
        #-Expack.security.transport.ssl.verification_mode=certificate \
        #-Expack.security.transport.ssl.keystore.path=certs/elastic-certificates.p12 \
        #-Expack.security.transport.ssl.truststore.path=certs/elastic-certificates.p12 \
        #-Expack.notification.slack.account.monitoring.url=https://hooks.slack.com/services/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
		#-Enetwork.host=$IPADDR
        #-Ebootstrap.memory_lock=true \
		#-Ecluster.initial_master_nodes=["tiger"] \

    if [ $? -eq 0 ]
    then
        PID=`ps -elf | egrep "elasticsearch" | egrep -v "es.sh|grep" | awk '{print $4}'`
        echo "succeed, pid: $PID"
    else
        echo "failed."
    fi
}

__main() {
    if [ $# -eq 0 ]
    then
        __usage
    else
        case $1 in
            deploy)
                __deploy
                ;;
            start)
                __start
                ;;
            stop)
                __stop
                ;;
            restart)
                __stop
                sleep 2
                __start
                ;;
            status)
                __status
                ;;
            *)
                __usage
                ;;
        esac
    fi
}

__main $@

exit 0
