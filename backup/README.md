# Collection backups

## What it does
Triggers Solr's native `BACKUP` collection action, which snapshots a collection's index files and metadata to a configured backup repository, timestamped so each run is independent.

## Behaviour
- **Repository abstraction**: `repository` names a backend configured cluster-side (e.g. a local path backed by a mounted Azure file share, or a cloud object-store repository plugin) — this script doesn't care which, it just targets whatever repository the cluster admin configured.
- **Timestamped backup names**: each backup gets a unique name (`${COLLECTION}-<timestamp>`), so a scheduled run never silently overwrites the previous one — retention/cleanup of old backups is a separate, explicit decision.
- **Runs against the live cluster, not storage directly**: Solr performs the snapshot itself (each shard leader copies its own index files), rather than something external trying to copy index files off disk while they're being actively written to.

## Why it's needed
A search index is derived data, but it's rarely cheap to derive — rebuilding it means re-indexing the entire source dataset through the full pipeline, which can take hours and load the upstream systems the data came from. A restorable backup turns "we lost a collection" from a multi-hour reindex into a restore operation.
