#!/bin/bash

# Author: Bin Wu <bin.wu@elastic.co>

PWD=`pwd`
JAVA=`which java`
VER=$(<ver)
IPADDR=$(hostname -I | cut -d ' ' -f 1)

__usage() {
    echo "Usage: auditbeat {start|stop|status|deploy}"
}

__status() {
    PID=`ps -elf | egrep "auditbeat" | egrep -v "ab.sh|grep" | awk '{print $4}'`
    if [ -z "$PID" ]
    then
        echo "auditbeat is not running"
    else
        echo "auditbeat is running, pid: $PID"
    fi
}

__stop() {
    PID=`ps -elf | egrep "auditbeat" | egrep -v "ab.sh|grep" | awk '{print $4}'`
    if [ -z "$PID" ]
    then
        echo "auditbeat is not running"
    else
        echo -n "Shutting down auditbeat ... "

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
	[ -d $PWD/data/ab/logs ] || mkdir -p $PWD/data/ab/logs

    # download the package
    [ -f $PWD/deploy/auditbeat.tar.gz ] || \
        curl https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-${VER}-linux-x86_64.tar.gz \
        --output $PWD/deploy/auditbeat.tar.gz
    [ -d $PWD/deploy/auditbeat ] || \
        mkdir $PWD/deploy/auditbeat; \
        tar xzf $PWD/deploy/auditbeat.tar.gz -C $PWD/deploy && \
        cp -af $PWD/deploy/auditbeat-${VER}-linux-x86_64/* $PWD/deploy/auditbeat

    #sudo chown -R root:root $PWD/deploy/auditbeat

    echo "please update the conf/auditbeat.yml file then start the service."
}

__start() {
    echo -n "Starting auditbeat ... "

    CONF_FILE=$PWD/conf/auditbeat.yml
    #sudo chown root $CONF_FILE

    sudo $PWD/deploy/auditbeat/auditbeat \
        -e -c $CONF_FILE \
        --strict.perms=false \
        -d "publish" > /dev/null 2>&1 &

    if [ $? -eq 0 ]
    then
        PID=`ps -elf | egrep "auditbeat" | egrep -v "ab.sh|grep" | awk '{print $4}'`
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
