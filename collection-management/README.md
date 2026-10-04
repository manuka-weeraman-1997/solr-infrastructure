# Collection management

## What it does
Creates/manages SolrCloud collections (an index and its sharding/replication layout) via Solr's HTTP Collections API, rather than through Terraform.

## Why this isn't Terraform
Terraform manages infrastructure state (VMs, networks, disks). A Solr collection is *application* state living inside an already-running cluster — its shard count, replication factor, and config set can change at runtime, and Solr itself (via ZooKeeper) is the source of truth for that state, not a `.tfstate` file. Modelling it in Terraform would mean Terraform and ZooKeeper could both believe they own the same state and disagree.

## Behaviour
- **`numShards`**: splits the collection's index across N shards so no single node needs to hold (or search) the entire dataset — this is what lets the index scale past what one machine's disk/CPU can handle.
- **`replicationFactor`**: each shard is copied to this many nodes. One replica serves reads/writes as the leader; the others stay in sync and take over if the leader's node fails — this is what SolrCloud actually uses the ZooKeeper-tracked cluster state for.
- **Idempotency caveat**: unlike the Ansible examples in the other repos, `CREATE` on an existing collection name fails rather than converging — this script is meant to be run once per collection, with changes to an existing collection handled via Solr's `MODIFYCOLLECTION`/`ADDREPLICA` actions instead.

## Why it's needed
Index layout decisions (how many shards, how many replicas) directly trade off query latency, indexing throughput, and fault tolerance — they need to be explicit, reviewable operations against the live cluster, not inferred from infrastructure changes.
