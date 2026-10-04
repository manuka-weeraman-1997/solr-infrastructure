#!/bin/bash
# Minimal bootstrap: point this Solr node at the shared ZooKeeper ensemble.
# Collection creation/replica placement is handled separately via the
# Collections API (see ../collection-management) - this script only starts
# the node so it can join the cluster.
echo "ZK_HOST=${zk_connect_string}" >> /etc/default/solr.in.sh
systemctl enable solr
systemctl start solr
