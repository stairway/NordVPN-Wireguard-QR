FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y wget iputils-ping curl wireguard jq net-tools qrencode && \
    wget -O /tmp/nordrepo.deb https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb && \
    apt-get install -y /tmp/nordrepo.deb && \
    apt-get update && \
    apt-get install -y nordvpn=3.15.2 && \
    apt-get remove -y wget nordvpn-release && \
    rm /tmp/nordrepo.deb && \
    apt-get clean
    
RUN mkdir /data && mkdir -p /etc/wireguard
VOLUME ["/etc/wireguard"]

COPY src/bin/* /usr/local/bin/

ENTRYPOINT /etc/init.d/nordvpn start && sleep 5 && \
  { set -e; nordvpn login --token "$(echo ${NORDVPN_TOKEN})" || { printf "There was a problem.\n"; exit 1; }; } && \
  /bin/bash -c "$@"

CMD NordVpnToWireguard.sh