#!/bin/bash

# Author: Bin Wu <bin.wu@elastic.co>

PWD=`pwd`
JAVA=`which java`
VER=1.16.0
IPADDR=$(hostname -I | cut -d ' ' -f 1)
PIDFILE=$PWD/conf/nginx/nginx.pid
CONF=$PWD/conf/nginx/nginx.conf
CONF_TEMPLATE=$PWD/conf/nginx/nginx.conf.template

__usage() {
    echo "Usage: nginx {start|stop|status|deploy|test}"
}

__status() {
    PID=`ps -elf | egrep "nginx" | egrep -v "ngx.sh|grep" | awk '{print $4}'`
    if [ -z "$PID" ]
    then
        echo "nginx is not running"
    else
        echo "nginx is running, pid: $PID"
    fi
}

__stop() {
    # kill -QUIT $( cat $PIDFILE )
    PID=`ps -elf | egrep "nginx" | egrep -v "ngx.sh|grep" | awk '{print $4}'`
    if [ -z "$PID" ]
    then
        echo "nginx is not running"
    else
        echo -n "Shutting down nginx ... "

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
	[ -d $PWD/data/nginx/log ] || mkdir -p $PWD/data/nginx/log

    # download the package
	[ -f $PWD/deploy/nginx.tar.gz ] || \
		curl http://nginx.org/download/nginx-$VER.tar.gz \
		--output $PWD/deploy/nginx.tar.gz
	[ -d $PWD/deploy/nginx ] || \
		mkdir $PWD/deploy/nginx; \
		tar xzf $PWD/deploy/nginx.tar.gz -C $PWD/deploy && \
		cp -af $PWD/deploy/nginx-$VER/* $PWD/deploy/nginx

	if [ ! -d $PWD/conf/nginx ]
	then
		mkdir -p $PWD/conf/nginx
		cp -a $PWD/deploy/nginx/config/* $PWD/conf/nginx/
	fi

    sed "s/%PWD%/$PWD/g" $CONF_TEMPLATE > $CONF

    __test_conf
}

__test_conf() {
    $PWD/deploy/nginx/bin/nginx -t -c $PWD/conf/nginx/nginx.conf -g "pid /var/run/nginx.pid; worker_processes 2;"
}

__start() {
    #__deploy

    echo -n "Starting nginx ... "

    $PWD/deploy/nginx/bin/nginx -c $PWD/conf/nginx/nginx.conf -g "pid /var/run/nginx.pid; worker_processes 2;"

    if [ $? -eq 0 ]
    then
        PID=`ps -elf | egrep "nginx" | egrep -v "ngx.sh|grep" | awk '{print $4}'`
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
            test)
                __test_conf
                ;;
            *)
                __usage
                ;;
        esac
    fi
}

__main $@

exit 0
