#!/usr/bin/env bash

set -e

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

cd "${SCRIPT_DIR}/../"

docker build -f docker/Dockerfile -t nordvpn:local docker
