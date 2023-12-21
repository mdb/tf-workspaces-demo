#!/bin/bash

# gresau/localstack-persist can seemingly experience a delay reflecting an S3
# object in store.json; this can lead to race conditions in which an s3 object
# that is present in localstack-data/s3/assets is not yet reflected in
# store.json, and is therefore unknown to the localstack S3 API.

default_workspace_count="$(jq '.include | length' workspaces.json)"
workspace_count="${1:-$default_workspace_count}"
attempts=0
max_attempts=5
initial_wait_period="${2:-0}"

sleep "$initial_wait_period"

until [ "$(jq '.data["000000000000"]["us-east-1"]["_global"]["buckets"]["tf-workspaces-demo"]["objects"]["_store"] | keys | length' localstack-data/s3/store.json)" -eq "${workspace_count}" ] ; do
  if [ "${attempts}" -eq "${max_attempts}" ]; then
    persisted_objects=$(jq '.data["000000000000"]["us-east-1"]["_global"]["buckets"]["tf-workspaces-demo"]["objects"]["_store"] | keys' localstack-data/s3/store.json)

    echo "Max attempts reached; expected ${workspace_count} workspace objects; found:"
    echo "${persisted_objects}"
    exit 1
  fi

  attempts=$((attempts + 1))

  sleep 5
done
