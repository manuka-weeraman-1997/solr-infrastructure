# ZooKeeper ensemble

## What it does
Coordinates the SolrCloud cluster: which node holds which shard/replica, which replica is the leader for a shard, and overall cluster state (collection configs, live nodes). SolrCloud nodes are stateless about this — they all read it from ZooKeeper.

## Behaviour
- **Fixed VMs, not a scale set**: ZooKeeper's consensus protocol (ZAB) requires each member to have a stable, known identity (`myid`) and a fixed position in every other member's server list. A scale set can silently replace an instance with a brand new one; a static 3-node deployment here means node identity survives a reboot or redeploy of that specific node.
- **Odd number of nodes (3)**: quorum needs a strict majority — 3 nodes tolerates 1 failure, 5 tolerates 2. An even count (e.g. 4) adds a node without buying extra fault tolerance, since the majority threshold doesn't change.
- **Static private IPs**: every node's `zoo.cfg` lists all ensemble members by IP (`local.server_lines`) — those IPs must not change across redeploys, or the ensemble can't re-form quorum.

## Why it's needed
Without a shared, consistent coordination layer, SolrCloud nodes would have no agreed-upon view of which node owns which shard or which replica is currently the leader — two nodes could both believe they're the leader for the same shard during a network partition (split brain), corrupting writes. ZooKeeper gives the cluster a single source of truth for that state.
