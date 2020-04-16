#!/bin/bash

# Author: Bin Wu <binwu@google.com>

pwd=`pwd`
ipaddr=$(hostname -I | cut -d ' ' -f 1)
cluster_name=elk
region=asia-east1
# zone=asia-east1-a
project_id=google.com:bin-wus-learning-center
default_pool=default-pool

es_cluster_name=dingo

__usage() {
    echo "Usage: ./bin/es.sh {deploy|password|status}"
}

__deploy() {
    kubectl apply -f $pwd/deploy/es.yml
}

__status() {
    passwd=$(__password)
    lb_ip=`kubectl get services dingo-es-http -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`

    curl -u "elastic:$passwd" -k "https://$lb_ip:9200"
}

__password() {
    kubectl get secret ${es_cluster_name}-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode
}

__main() {
    if [ $# -eq 0 ]
    then
        __usage
    else
        case $1 in
            deploy|d)
                __deploy
                ;;
            password|pwd|pw|p)
                __password
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
