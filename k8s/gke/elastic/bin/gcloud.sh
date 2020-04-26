#!/bin/bash

# Author: Bin Wu <binwu@google.com>

pwd=`pwd`

__usage() {
    echo "Usage: ./bin/gcloud.sh {install|init|update|kubectl}"
}

__inst() {
    curl https://sdk.cloud.google.com | bash

    exec -l $SHELL

    __init
}

__init() {
    gcloud init
}

__update() {
    gcloud components update
}

__kubectl() {
    gcloud components install kubectl
}

__main() {
    if [ $# -eq 0 ]
    then
        __usage
    else
        case $1 in
            install)
                __inst
                ;;
            init)
                __init
                ;;
            update)
                __update
                ;;
            kubectl)
                __kubectl
                ;;
            *)
                __usage
                ;;
        esac
    fi
}

__main $@
