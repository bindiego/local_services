#!/bin/bash

./deploy/elasticsearch/bin/x-pack/certutil ca
./deploy/elasticsearch/bin/x-pack/certutil cert --ca elastic-stack-ca.p12

echo 'copy the certificate to deploy/es/config/certs or specify other path in es.sh'
