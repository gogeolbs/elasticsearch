#!/bin/bash
echo "Waiting for the IP assignment: elasticsearch"
NETWORK_INTERFACE=${NETWORK_INTERFACE:='eth0'}
/opt/pipework/pipework --wait -i $NETWORK_INTERFACE

if [[ -z $ES_REPLICAS ]]; then
	ES_REPLICAS=1
fi

if [[ -z $ES_SHARDS ]]; then
	ES_SHARDS=1
fi

if [[ -z $ES_CLUSTER_NAME ]]; then
	ES_CLUSTER_NAME="es_cluster_test"
fi

if [[ -z $ES_IP ]]; then
	ES_IP=$(ifconfig $NETWORK_INTERFACE | grep "inet " | grep -v "127.0.0.1/8" | awk '{print $2}' | awk '{print substr($1,6)}')
fi

ES_DATA_DIR=${ES_DATA_DIR:=/elasticsearch}
ES_LOG_DIR=${ES_LOG_DIR:=/elasticsearch}

echo "ES_CLUSTER_NAME: $ES_CLUSTER_NAME"
echo "ES_IP: $ES_IP"
echo "ES_REPLICAS: $ES_REPLICAS"
echo "ES_SHARDS: $ES_SHARDS"

sed -ir "s/.*index.number_of_replicas.*/index.number_of_replicas: $ES_REPLICAS/g" config/elasticsearch.yml
sed -ir "s/.*index.number_of_shards.*/index.number_of_shards: $SHARDS/g" config/elasticsearch.yml

sed -ri "s/.*cluster.name.*/cluster.name: $ES_CLUSTER_NAME/g" config/elasticsearch.yml
sed -ri "s/.*network.host.*/network.host: $ES_IP/g" config/elasticsearch.yml
sed -ri "s;.*path.data.*;path.data: $ES_DATA_DIR;g" config/elasticsearch.yml
sed -ri "s;.*path.logs.*;path.logs: $ES_LOG_DIR;g" config/elasticsearch.yml

echo "http.cors.enabled: true" >> config/elasticsearch.yml

if [[ -n $GCLOUD_PROJ ]] && [[ -n $GCLOUD_ZONE ]]; then
	# Plugin to gClould Servers
	echo "#Setup elasticsearch cloud gce plugin\n"
	echo "cloud:" >> config/elasticsearch.yml
	echo "  gce:" >> config/elasticsearch.yml
	echo "      project_id: $GCLOUD_PROJ" >> config/elasticsearch.yml
	echo "      zone: $GCLOUD_ZONE" >> config/elasticsearch.yml
	echo "discovery:" >> config/elasticsearch.yml
	echo "  type: gce" >> config/elasticsearch.yml
fi

if [[ -n $LIST_ES ]]; then
	sed -ri "s/.*discovery.zen.ping.unicast.hosts.*/discovery.zen.ping.unicast.hosts: [$LIST_ES]/g" config/elasticsearch.yml
fi

/elasticsearch/bin/elasticsearch
