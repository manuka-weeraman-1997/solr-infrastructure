#!/bin/bash
# Triggers a SolrCloud collection backup to a shared backup repository
# (configured cluster-side to point at Azure Blob Storage / a mounted share).
# Intended to run on a schedule (cron / Azure Automation runbook), not on
# every deploy - backups are a time-based policy, not an infra change.
set -euo pipefail

SOLR_HOST="${1:?usage: backup-collection.sh <solr-host> <collection-name> <repository-name>}"
COLLECTION="${2:?}"
REPOSITORY="${3:?}"
BACKUP_NAME="${COLLECTION}-$(date +%Y%m%d%H%M%S)"

curl -sS "http://${SOLR_HOST}:8983/solr/admin/collections" \
  --data-urlencode "action=BACKUP" \
  --data-urlencode "name=${BACKUP_NAME}" \
  --data-urlencode "collection=${COLLECTION}" \
  --data-urlencode "repository=${REPOSITORY}" \
  --data-urlencode "location=/backups/${COLLECTION}"
