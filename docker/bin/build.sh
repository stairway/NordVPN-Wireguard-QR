#!/usr/bin/env bash

set -e

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

cd "${SCRIPT_DIR}/../../"

build_cmd=("docker" "build")
! "${DEBUG:-false}" || build_cmd+=("--no-cache")
build_cmd+=("-f" "docker/Dockerfile" "-t" "nordvpn:local" "docker")

set -x
"${build_cmd[@]}"
