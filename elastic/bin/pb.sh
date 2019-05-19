#!/bin/bash

# Author: Bin Wu <bin.wu@elastic.co>

PWD=`pwd`
JAVA=`which java`
VER=$(<ver)
IPADDR=$(hostname -I | cut -d ' ' -f 1)

__usage() {
    echo "Usage: packetbeat {start|stop|status|deploy}"
}

__status() {
    PID=`ps -elf | egrep "packetbeat" | egrep -v "pb.sh|grep" | awk '{print $4}'`
    if [ -z "$PID" ]
    then
        echo "packetbeat is not running"
    else
        echo "packetbeat is running, pid: $PID"
    fi
}

__stop() {
    PID=`ps -elf | egrep "packetbeat" | egrep -v "pb.sh|grep" | awk '{print $4}'`
    if [ -z "$PID" ]
    then
        echo "packetbeat is not running"
    else
        echo -n "Shutting down packetbeat ... "

        sudo kill -9 $PID
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
	[ -d $PWD/data/pb/logs ] || mkdir -p $PWD/data/pb/logs

    # download the package
    [ -f $PWD/deploy/packetbeat.tar.gz ] || \
        curl https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-${VER}-linux-x86_64.tar.gz \
        --output $PWD/deploy/packetbeat.tar.gz
    [ -d $PWD/deploy/packetbeat ] || \
        mkdir $PWD/deploy/packetbeat; \
        tar xzf $PWD/deploy/packetbeat.tar.gz -C $PWD/deploy && \
        cp -af $PWD/deploy/packetbeat-${VER}-linux-x86_64/* $PWD/deploy/packetbeat

    [ -d $PWD/conf/packetbeat ] || mkdir -p $PWD/conf/packetbeat
    [ -f $PWD/conf/packetbeat/packetbeat.yml ] || \
        cp $PWD/conf/packetbeat.yml $PWD/conf/packetbeat/

    echo "please update the conf/packetbeat.yml file then start the service."
}

__start() {
    echo -n "Starting packetbeat ... "

    CONF_FILE=$PWD/conf/packetbeat/packetbeat.yml
    # sudo chown root $CONF_FILE

    sudo $PWD/deploy/packetbeat/packetbeat \
        -e -c $CONF_FILE \
        --strict.perms=false \
        -d "publish" > /dev/null 2>&1 &

    if [ $? -eq 0 ]
    then
        PID=`ps -elf | egrep "packetbeat" | egrep -v "pb.sh|grep" | awk '{print $4}'`
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
