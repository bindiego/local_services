#!/usr/bin/env bash

PID=`ps -elf | egrep "$@" | egrep -v "grep" | awk '{print $4}'`

if [ -z "$PID" ]
then
    echo "$@ is not running"
else
    echo "$@ pid: ${PID}"
    echo "Shutting down $@ ... "

    kill -9 $PID 
    if [ $? -eq 0 ]
    then
        echo -n "succeed."
    else
        echo -n "failed."

    fi
fi
