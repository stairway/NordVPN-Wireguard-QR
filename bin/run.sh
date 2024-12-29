#!/usr/bin/env sh

set -eu

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

cd "${SCRIPT_DIR}/../"

test -f data/.nordvpn_token && err=0 || err=$?
test $err -eq 0 || (echo "Token not found in data/.nordvpn_token file" && exit $err)

set -x
# NORDVPN_TOKEN="$(cat ${PWD}/data/.nordvpn_token)"
docker run --rm -it --privileged --device=/dev/net/tun \
	-v "$PWD/.wireguard":/etc/wireguard \
  -v "$PWD/data":/data \
	-e "NORDVPN_TOKEN=${NORDVPN_TOKEN-}" \
	-e "COUNTRY=${1-}" \
	-e "CITY=${2-}" \
  -e "DEBUG=${DEBUG-}" \
  --init \
	nordvpn:local
