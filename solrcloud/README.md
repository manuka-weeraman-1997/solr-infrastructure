# SolrCloud node fleet

## What it does
Runs the Solr nodes that actually hold index shards/replicas and serve search queries. Unlike a typical stateless application tier, this is a fixed-size fleet (`var.node_count`), not autoscaled on load.

## Behaviour
- **No CPU-based autoscaling**: SolrCloud distributes shards/replicas across nodes explicitly (via the Collections API), and tracks which node holds which replica in ZooKeeper. If the fleet silently scaled in under low load, it would take index replicas with it — the fix (re-replicating shards) is far more disruptive than losing a few idle compute instances. Capacity changes here are planned (`node_count` + an explicit reshard/replica move), not automatic.
- **Separate data disk**: the Lucene index lives on its own managed disk (`data_disk`), not the OS disk — an OS-level upgrade or re-image never risks index data, and the disk can be sized/IOPS-tuned independently of the OS disk.
- **Rolling upgrades, one-third at a time**: `rolling_upgrade_policy` caps each batch at ~34% of nodes (roughly one node at a time for a 3-node cluster) — SolrCloud tolerates a minority of nodes being briefly unavailable (reads/writes continue against the remaining replicas) but not a majority, so the batch size is deliberately conservative.
- **Bootstrap only joins the cluster**: `cloud-init.sh.tpl` just points the node at ZooKeeper (`zk_connect_string`) and starts the service — it doesn't create collections or assign replicas, because that's cluster state, not node state (see `../collection-management`).

## Why it's needed
Search needs low-latency, horizontally distributed indexing and querying across a dataset too large (or too hot) for a single node — SolrCloud shards the index across nodes and replicates each shard for availability, coordinating all of that through ZooKeeper (see `../zookeeper`).
