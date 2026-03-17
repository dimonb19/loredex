#!/usr/bin/env sh

set -eu


echo "Creating container"
id=$(docker create "$1")

echo "Copying files"
docker cp "$id:$2" "$3"

echo "Removing container"
docker rm -v "$id"
