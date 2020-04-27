#!/bin/bash

# Author: Bin Wu <bin.wu@elastic.co>

PWD=`pwd`
JAVA=`which java`
VER=$(<ver)
IPADDR=$(hostname -I | cut -d ' ' -f 1)

__usage() {
    echo "Usage: filebeat {start|stop|status|deploy}"
}

__status() {
    PID=`ps -elf | egrep "filebeat" | egrep -v "fb.sh|grep" | awk '{print $4}'`
    if [ -z "$PID" ]
    then
        echo "filebeat is not running"
    else
        echo "filebeat is running, pid: $PID"
    fi
}

__stop() {
    PID=`ps -elf | egrep "filebeat" | egrep -v "fb.sh|grep" | awk '{print $4}'`
    if [ -z "$PID" ]
    then
        echo "filebeat is not running"
    else
        echo -n "Shutting down filebeat ... "

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
	[ -d $PWD/data/fb/logs ] || mkdir -p $PWD/data/fb/logs

    # download the package
    [ -f $PWD/deploy/filebeat.tar.gz ] || \
        curl https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${VER}-linux-x86_64.tar.gz \
        --output $PWD/deploy/filebeat.tar.gz
    [ -d $PWD/deploy/filebeat ] || \
        mkdir $PWD/deploy/filebeat; \
        tar xzf $PWD/deploy/filebeat.tar.gz -C $PWD/deploy && \
        cp -af $PWD/deploy/filebeat-${VER}-linux-x86_64/* $PWD/deploy/filebeat

    # sudo chown -R root:root $PWD/deploy/filebeat

    [ -d $PWD/conf/filebeat ] || mkdir -p $PWD/conf/filebeat
    [ -f $PWD/conf/filebeat/filebeat.yml ] || \
        cp $PWD/conf/filebeat.yml $PWD/conf/filebeat/
    [ -d $PWD/conf/filebeat/modules.d ] || \
        cp -a $PWD/deploy/filebeat/modules.d $PWD/conf/filebeat
    cp -a $PWD/deploy/filebeat/module \
        $PWD/deploy/filebeat/kibana \
        $PWD/deploy/filebeat/fields.yml $PWD/conf/filebeat

    echo "please update the conf/filebeat/filebeat.yml file then start the service."
}

__start() {
    echo -n "Starting filebeat ... "

    CONF_FILE=$PWD/conf/filebeat/filebeat.yml
    # sudo chown root $CONF_FILE

    sudo $PWD/deploy/filebeat/filebeat \
        -e -c $CONF_FILE \
        --path.config=$PWD/conf/filebeat \
        --strict.perms=false \
        -d "publish" > /dev/null 2>&1 &

    if [ $? -eq 0 ]
    then
        PID=`ps -elf | egrep "filebeat" | egrep -v "fb.sh|grep" | awk '{print $4}'`
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
