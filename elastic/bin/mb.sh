#!/bin/bash

# Author: Bin Wu <bin.wu@elastic.co>

PWD=`pwd`
JAVA=`which java`
VER=6.2.0
IPADDR=$(hostname -I | cut -d ' ' -f 1)

__usage() {
    echo "Usage: metricbeat {start|stop|status|deploy}"
}

__status() {
    PID=`ps -elf | egrep "metricbeat" | egrep -v "mb.sh|grep" | awk '{print $4}'`
    if [ -z "$PID" ]
    then
        echo "Metricbeat is not running"
    else
        echo "Metricbeat is running, pid: $PID"
    fi
}

__stop() {
    PID=`ps -elf | egrep "metricbeat" | egrep -v "mb.sh|grep" | awk '{print $4}'`
    if [ -z "$PID" ]
    then
        echo "Metricbeat is not running"
    else
        echo -n "Shutting down Metricbeat ... "

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
	[ -d $PWD/data/mb/logs ] || mkdir -p $PWD/data/mb/logs

    # download the package
    [ -f $PWD/deploy/metricbeat.tar.gz ] || \
        curl https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-${VER}-linux-x86_64.tar.gz \
        --output $PWD/deploy/metricbeat.tar.gz
    [ -d $PWD/deploy/metricbeat ] || \
        mkdir $PWD/deploy/metricbeat; \
        tar xzf $PWD/deploy/metricbeat.tar.gz -C $PWD/deploy && \
        cp -af $PWD/deploy/metricbeat-${VER}-linux-x86_64/* $PWD/deploy/metricbeat

    echo "please update the conf/metricbeat.yml file then start the service."
}

__start() {
    echo -n "Starting Metricbeat ... "

    CONF_FILE=$PWD/conf/metricbeat.yml
    sudo chown root $CONF_FILE

    sudo $PWD/deploy/metricbeat/metricbeat \
        -e -c $CONF_FILE \
        -d "publish" > /dev/null 2>&1 &

    if [ $? -eq 0 ]
    then
        PID=`ps -elf | egrep "metricbeat" | egrep -v "mb.sh|grep" | awk '{print $4}'`
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
