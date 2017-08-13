#!/bin/bash

wait-for-it.sh zookeeper:2181 -t 40
rc=$?
if [ $rc -ne 0 ]; then
    echo -e "\n---------------------------------------"
    echo -e " Apache ZooKeeper not ready! Exiting..."
    echo -e "---------------------------------------"
    exit $rc
fi

wait-for-it.sh hadoop:8020 -t 180
rc=$?
if [ $rc -ne 0 ]; then
    echo -e "\n---------------------------------------"
    echo -e "     Apache HDFS not ready! Exiting..."
    echo -e "---------------------------------------"
    exit $rc
fi

hdfs dfsadmin -safemode leave

wait-for-it.sh postgres:5432 -t 120
rc=$?
if [ $rc -ne 0 ]; then
    echo -e "\n---------------------------------------"
    echo -e "     PostgreSQL not ready! Exiting..."
    echo -e "---------------------------------------"
    exit $rc
fi

wait-for-it.sh hive:9083 -t 480
rc=$?
if [ $rc -ne 0 ]; then
    echo -e "\n---------------------------------------"
    echo -e "    Hive Metastore not ready! Exiting..."
    echo -e "---------------------------------------"
    exit $rc
fi

wait-for-it.sh hive:10000 -t 480
rc=$?
if [ $rc -ne 0 ]; then
    echo -e "\n---------------------------------------"
    echo -e "    HiveServer2 not ready! Exiting..."
    echo -e "---------------------------------------"
    exit $rc
fi

psql -h postgres -U postgres -c "CREATE DATABASE hue;"
hue syncdb --noinput
hue migrate --noinput

supervisorctl start hue

echo -e "\n\n--------------------------------------------------------------------------------"
echo -e "You can now access to the following Cloudera Hue Web UIs:\n"
echo -e "Cloudera Hue 		http://localhost:8000\n"
echo -e "IMPORTANT NOTE: at the first login remember to create a Hue username called 'hue'"
echo -e "in order to access with the correct permissions to the HDFS of the Hadoop docker"
echo -e "container."
echo -e "Otherwise you'll have to update the core-site.xml file in the hadoop_conf named"
echo -e "volume in order to add/update the following parameters:\n"
echo -e "\t\thadoop.proxyuser.<username>.groups"
echo -e "\t\thadoop.proxyuser.<username>.hosts"
echo -e "\nMantainer:   Matteo Capitanio <matteo.capitanio@gmail.com>"
echo -e "--------------------------------------------------------------------------------\n\n"




