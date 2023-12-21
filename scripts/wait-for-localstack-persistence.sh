#!/bin/bash

# gresau/localstack-persist can seemingly experience a delay reflecting an S3
# object in store.json; this can lead to race conditions in which an s3 object
# that is present in localstack-data/s3/assets is not yet reflected in
# store.json, and is therefore unknown to the localstack S3 API.

workspace="${1}"
attempts=0
max_attempts=5
initial_wait_period="${2:-0}"
query=".data[\"000000000000\"][\"us-east-1\"][\"_global\"][\"buckets\"][\"tf-workspaces-demo\"][\"objects\"][\"_store\"][\"env:/${workspace}/terraform.tfstate\"][\"size\"]"
real_size="$(wc -c "localstack-data/s3/assets/tf-workspaces-demo/env%3a%2f${workspace}%2fterraform.tfstate@null" | awk '{print $1}')"

sleep "$initial_wait_period"

until [ "$(jq -r "${query}" localstack-data/s3/store.json)" = "${real_size}" ]; do
  if [ "${attempts}" -eq "${max_attempts}" ]; then
    result=$(jq -r "${query}" localstack-data/s3/store.json)

    echo "Max attempts reached; expected S3 object with size ${real_size}; got: ${result}"
    exit 1
  fi

  attempts=$((attempts + 1))

  sleep 5
done
