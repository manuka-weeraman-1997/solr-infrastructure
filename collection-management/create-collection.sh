#!/bin/bash
# Creates a SolrCloud collection with an explicit shard/replication layout.
# Run against any live node - SolrCloud forwards the request through
# ZooKeeper to wherever it needs to go.
set -euo pipefail

SOLR_HOST="${1:?usage: create-collection.sh <solr-host> <collection-name> <num-shards> <replication-factor>}"
COLLECTION="${2:?}"
NUM_SHARDS="${3:-3}"
REPLICATION_FACTOR="${4:-2}"

curl -sS "http://${SOLR_HOST}:8983/solr/admin/collections" \
  --data-urlencode "action=CREATE" \
  --data-urlencode "name=${COLLECTION}" \
  --data-urlencode "numShards=${NUM_SHARDS}" \
  --data-urlencode "replicationFactor=${REPLICATION_FACTOR}" \
  --data-urlencode "collection.configName=${COLLECTION}"
