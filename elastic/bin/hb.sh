#!/bin/bash

# Author: Bin Wu <binwu@google.com>

PWD=`pwd`
JAVA=`which java`
VER=$(<ver)
IPADDR=$(hostname -I | cut -d ' ' -f 1)

__usage() {
    echo "Usage: heartbeat {start|stop|status|deploy}"
}

__status() {
    PID=`ps -elf | egrep "heartbeat" | egrep -v "hb.sh|grep" | awk '{print $4}'`
    if [ -z "$PID" ]
    then
        echo "heartbeat is not running"
    else
        echo "heartbeat is running, pid: $PID"
    fi
}

__stop() {
    PID=`ps -elf | egrep "heartbeat" | egrep -v "hb.sh|grep" | awk '{print $4}'`
    if [ -z "$PID" ]
    then
        echo "heartbeat is not running"
    else
        echo -n "Shutting down heartbeat ... "

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
	[ -d $PWD/data/hb/logs ] || mkdir -p $PWD/data/hb/logs

    # download the package
    [ -f $PWD/deploy/heartbeat.tar.gz ] || \
        curl https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-${VER}-linux-x86_64.tar.gz \
        --output $PWD/deploy/heartbeat.tar.gz
    [ -d $PWD/deploy/heartbeat ] || \
        mkdir $PWD/deploy/heartbeat; \
        tar xzf $PWD/deploy/heartbeat.tar.gz -C $PWD/deploy && \
        cp -af $PWD/deploy/heartbeat-${VER}-linux-x86_64/* $PWD/deploy/heartbeat

    #sudo chown -R root:root $PWD/deploy/heartbeat

    [ -d $PWD/conf/heartbeat ] || mkdir -p $PWD/conf/heartbeat
    [ -f $PWD/conf/heartbeat/heartbeat.yml ] || \
        cp $PWD/conf/heartbeat.yml $PWD/conf/heartbeat/

    echo "please update the conf/heartbeat/heartbeat.yml file then start the service."
}

__start() {
    echo -n "Starting heartbeat ... "

    CONF_FILE=$PWD/conf/heartbeat/heartbeat.yml
    #sudo chown root $CONF_FILE

    sudo $PWD/deploy/heartbeat/heartbeat \
        -e -c $CONF_FILE \
        --strict.perms=false \
        -d "publish" > /dev/null 2>&1 &

    if [ $? -eq 0 ]
    then
        PID=`ps -elf | egrep "heartbeat" | egrep -v "hb.sh|grep" | awk '{print $4}'`
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
