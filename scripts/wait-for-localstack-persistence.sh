#!/bin/bash

# gresau/localstack-persist can seemingly experience a delay reflecting an S3
# object in store.json; this can lead to race conditions in which an s3 object
# that is present in localstack-data/s3/assets is not yet reflected in
# store.json, and is therefore unknown to the localstack S3 API.

workspace="${1}"
attempts=0
max_attempts=5
initial_wait_period="${2:-0}"
query=".data[\"000000000000\"][\"us-east-1\"][\"_global\"][\"buckets\"][\"tf-workspaces-demo\"][\"objects\"][\"_store\"][\"env:/${workspace}/terraform.tfstate\"][\"key\"]"

sleep "$initial_wait_period"

jq -r "${query}" localstack-data/s3/store.json

until [ "$(jq -r "${query}" localstack-data/s3/store.json)" = "env:/${workspace}/terraform.tfstate" ]; do
  if [ "${attempts}" -eq "${max_attempts}" ]; then
    result=$(jq '.data["000000000000"]["us-east-1"]["_global"]["buckets"]["tf-workspaces-demo"]["objects"]["_store"]' localstack-data/s3/store.json)

    echo "Max attempts reached; expected to find ${workspace} key in S3; found:"
    echo "${result}"
    exit 1
  fi

  attempts=$((attempts + 1))

  sleep 5
done
