#!/bin/bash
echo "Waiting for the IP assignment: elasticsearch"
NETWORK_INTERFACE=${NETWORK_INTERFACE:='eth1'}
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
	ES_IP=$(ifconfig eth1 | grep "inet " | grep -v "127.0.0.1/8" | awk '{print $2}' | awk '{print substr($1,6)}')
fi

echo "ES_CLUSTER_NAME: $ES_CLUSTER_NAME"
echo "ES_IP: $ES_IP"
echo "ES_REPLICAS: $ES_REPLICAS"
echo "ES_SHARDS: $ES_SHARDS"

sed -ir "s/.*index.number_of_replicas.*/index.number_of_replicas: $ES_REPLICAS/g" config/elasticsearch.yml
sed -ir "s/.*index.number_of_shards.*/index.number_of_shards: $SHARDS/g" config/elasticsearch.yml

sed -ri "s/.*cluster.name.*/cluster.name: $ES_CLUSTER_NAME/g" config/elasticsearch.yml
sed -ri "s/.*network.host.*/network.host: $ES_IP/g" config/elasticsearch.yml

echo "http.cors.enabled: true" >> config/elasticsearch.yml

/elasticsearch/bin/elasticsearch
