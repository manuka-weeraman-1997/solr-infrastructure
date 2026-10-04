# Solr Infrastructure

Infrastructure-as-code and operational automation for running SolrCloud: the compute fleet, its ZooKeeper coordination layer, and the collection/backup operations that Terraform deliberately doesn't own.

| Component | What it is | Why it's here |
|---|---|---|
| [`solrcloud/`](solrcloud) | Fixed-size VMSS running Solr nodes | The search cluster itself — deliberately not autoscaled (see its README) |
| [`zookeeper/`](zookeeper) | 3-node ZooKeeper ensemble | Cluster coordination: shard/replica ownership, leader election |
| [`collection-management/`](collection-management) | Collections API scripts | Index layout (shards/replicas) is application state, not infra state |
| [`backup/`](backup) | Scheduled collection backup | Disaster recovery for an index that's expensive to rebuild |

See also: [`aws-infrastructure`](https://github.com/manuka-weeraman-1997/aws-infrastructure) and [`azure-infrastructure`](https://github.com/manuka-weeraman-1997/azure-infrastructure) for the general-purpose compute/streaming/load-balancing patterns this builds on.

Author: Manuka Weeraman — Platform Engineer
