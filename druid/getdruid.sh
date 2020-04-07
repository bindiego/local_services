#!/bin/bash -ex

pwd=`pwd`
druid_ver=0.9.2

curl -O http://static.druid.io/artifacts/releases/druid-${druid_ver}-bin.tar.gz && \
  tar xzf druid-${druid_ver}-bin.tar.gz && \
	cd druid-${druid_ver} && ./bin/init; cd ${pwd}

