#!/bin/bash

./deploy/elasticsearch/bin/elasticsearch-plugin install ingest-user-agent
./deploy/elasticsearch/bin/elasticsearch-plugin install ingest-geoip
./deploy/elasticsearch/bin/elasticsearch-plugin install ingest-attachment

# ./deploy/kibana/bin/kibana-plugin install x-pack

