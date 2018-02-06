#!/bin/bash

./deploy/elasticsearch/bin/elasticsearch-plugin install x-pack

# start elastic search
# ./deploy/elasticsearch/bin/x-pack/setup-passwords interactive

./deploy/kibana/bin/kibana-plugin install x-pack

# update kibana config file with
# elasticsearch.url: "http://localhost:9200"
# elasticsearch.username: "kibana"
# elasticsearch.password:  "<pwd>"
