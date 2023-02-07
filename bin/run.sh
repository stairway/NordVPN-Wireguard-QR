#!/usr/bin/env sh

set -e

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

cd "${SCRIPT_DIR}/../"

docker run -it --privileged --device=/dev/net/tun \
	-v "$(pwd)/wireguard":/etc/wireguard \
	-e "NORDVPN_TOKEN=0d579ed1979abc992bc41c626b726b4fba69866e6be4861cf77224f004c044fc" \
	-e "COUNTRY=${1}" \
	-e "CITY=${2}" \
	nordvpn:local
