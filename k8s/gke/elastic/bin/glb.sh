#!/bin/bash

# Author: Bin Wu <binwu@google.com>

pwd=`pwd`
glb_name=elk-static-ip

__usage() {
    echo "Usage: ./bin/glb.sh {reserve|release}"
}

__reserve_ip() {
    gcloud compute addresses create $glb_name --global
}

__release_ip() {
    echo "Y" | gcloud compute addresses delete $glb_name --global
}

__status() {
    gcloud compute addresses list --filter="name=$glb_name"
}

__main() {
    if [ $# -eq 0 ]
    then
        __usage
    else
        case $1 in
            reserve|r)
                __reserve_ip
                ;;
            release|clean)
                __release_ip
                ;;
            status|s)
                __status
                ;;
            *)
                __usage
                ;;
        esac
    fi
}

__main $@
