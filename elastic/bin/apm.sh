#!/bin/bash

# Author: Bin Wu <bin.wu@elastic.co>

PWD=`pwd`
JAVA=`which java`
VER=$(<ver)
IPADDR=$(hostname -I | cut -d ' ' -f 1)

__usage() {
    echo "Usage: apm {start|stop|status|deploy|setup}"
}

__status() {
    PID=`ps -elf | egrep "apm" | egrep -v "apm.sh|grep" | awk '{print $4}'`
    if [ -z "$PID" ]
    then
        echo "apm is not running"
    else
        echo "apm is running, pid: $PID"
    fi
}

__stop() {
    PID=`ps -elf | egrep "apm" | egrep -v "apm.sh|grep" | awk '{print $4}'`
    if [ -z "$PID" ]
    then
        echo "apm is not running"
    else
        echo -n "Shutting down apm ... "

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

    # setup directories
	[ -d $PWD/deploy ] || mkdir -p $PWD/deploy
	[ -d $PWD/data ] || mkdir -p $PWD/data
	[ -d $PWD/data/apm/logs ] || mkdir -p $PWD/data/apm/logs

    # download the package
	[ -f $PWD/deploy/apm.tar.gz ] || \
        curl https://artifacts.elastic.co/downloads/apm-server/apm-server-${VER}-linux-x86_64.tar.gz \
		-o $PWD/deploy/apm.tar.gz
	[ -d $PWD/deploy/apm ] || \
        mkdir $PWD/deploy/apm; \
		tar xzf $PWD/deploy/apm.tar.gz -C $PWD/deploy && \
		cp -af $PWD/deploy/apm-server-${VER}-linux-x86_64/* $PWD/deploy/apm

    [ -d $PWD/conf/apm ] || mkdir -p $PWD/conf/apm
    [ -f $PWD/conf/apm/apm-server.yml ] || \
        cp $PWD/conf/apm-server.yml $PWD/conf/apm/
    cp -a $PWD/deploy/apm/fields.yml \
        $PWD/deploy/apm/ingest \
        $PWD/deploy/apm/kibana $PWD/conf/apm

    echo "please update the conf/apm/apm-server.yml file then start the service."
}

__setup() {
    ln -s $PWD/deploy/apm/apm-server.yml
	$PWD/deploy/apm/apm-server \
        -E setup.kibana.host=$IPADDR:5601 \
        setup
}

__start() {
    echo -n "Starting apm ... "

    CONF_FILE=$PWD/conf/apm/apm-server.yml

	$PWD/deploy/apm/apm-server \
        -e -c $CONF_FILE \
        --path.config=$PWD/conf/apm \
        --path.data=$PWD/data/apm \
        --path.logs=$PWD/data/apm/logs \
        --strict.perms=false \
        -E output.elasticsearch.hosts=$IPADDR:9200 \
        -E apm-server.host=$IPADDR:8200 \
        -E logging.to_files=true \
        -d "publish" > /dev/null 2>&1 &
        # -E logging.files.path=$PWD/data/apm/logs \

    if [ $? -eq 0 ]
    then
        PID=`ps -elf | egrep "apm" | egrep -v "apm.sh|grep" | awk '{print $4}'`
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
            setup)
                __setup
                ;;
            *)
                __usage
                ;;
        esac
    fi
}

__main $@

exit 0
