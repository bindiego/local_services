#!/bin/bash

# Author: Bin Wu <bin.wu@elastic.co>

PWD=`pwd`
JAVA=`which java`
VER=$(<ver)
IPADDR=$(hostname -I | cut -d ' ' -f 1)

__usage() {
    echo "Usage: esd {images|es|kbn|beats}"
}

__images() {
    docker pull docker.elastic.co/kibana/kibana:${VER}
    docker pull docker.elastic.co/elasticsearch/elasticsearch:${VER}
    #docker pull docker.elastic.co/logstach/logstash:${VER}
    #docker pull docker.elastic.co/apm/apm-server:${VER}
    #docker pull docker.elastic.co/beats/heartbeat:${VER}
    docker pull docker.elastic.co/beats/packetbeat:${VER}
    docker pull docker.elastic.co/beats/metricbeat:${VER}
    docker pull docker.elastic.co/beats/filebeat:${VER}
}

__kibana() {
    echo "Starting Kibana"
}

__main() {
    if [ $# -eq 0 ]
    then
        __usage
    else
        case $1 in
            images)
                __images
                ;;
            kbn)
                __kibana
                ;;
            stop)
                __stop
                ;;
            status)
                docker ps -a
                ;;
            *)
                __usage
                ;;
        esac
    fi
}

__main $@

exit 0
