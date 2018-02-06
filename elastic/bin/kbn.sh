#!/bin/bash

# Author: Bin Wu <bin.wu@elastic.co>

PWD=`pwd`
JAVA=`which java`
VER=6.1.3
IPADDR=$(hostname -I | cut -d ' ' -f 1)

__usage() {
    echo "Usage: kibana {start|stop|status|deploy}"
}

__status() {
    PID=`ps -elf | egrep "kibana" | egrep -v "kbn.sh|grep" | awk '{print $4}'`
    if [ -z "$PID" ]
    then
        echo "kibana is not running"
    else
        echo "kibana is running, pid: $PID"
    fi
}

__stop() {
    PID=`ps -elf | egrep "kibana" | egrep -v "kbn.sh|grep" | awk '{print $4}'`
    if [ -z "$PID" ]
    then
        echo "kibana is not running"
    else
        echo -n "Shutting down kibana ... "

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
    # setup directories
	[ -d $PWD/deploy ] || mkdir -p $PWD/deploy
	[ -d $PWD/data ] || mkdir -p $PWD/data
	[ -d $PWD/data/kbn/logs ] || mkdir -p $PWD/data/kbn/logs

    # download the package
	[ -f $PWD/deploy/kibana.tar.gz ] || \
		curl https://artifacts.elastic.co/downloads/kibana/kibana-${VER}-linux-x86_64.tar.gz \
		-o $PWD/deploy/kibana.tar.gz
	[ -d $PWD/deploy/kibana ] || \
		tar xzf $PWD/deploy/kibana.tar.gz -C $PWD/deploy && \
		mv $PWD/deploy/kibana-${VER}-linux-x86_64 $PWD/deploy/kibana

    echo "please update the deploy/kibana/config/kibana.yml file then start the service."
}

__start() {
    echo -n "Starting kibana ... "

	$PWD/deploy/kibana/bin/kibana \
		-p 5601 \
		--pid.file=$PWD/deploy/kbn.pid \
		--path.data=$PWD/data/kbn \
		--host $IPADDR \
		-e http://$IPADDR:9200 \
		-l $PWD/data/kbn/logs/kbn.log > /dev/null 2>&1 &

    if [ $? -eq 0 ]
    then
        PID=`ps -elf | egrep "kibana" | egrep -v "kbn.sh|grep" | awk '{print $4}'`
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
