#!/usr/bin/env bash

export IMAGE=$1

docker-compose -f compose.yaml up --detach

echo 'success'