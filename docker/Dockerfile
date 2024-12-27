FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y wget iputils-ping curl wireguard jq net-tools qrencode && \
    wget -O /tmp/nordrepo.deb https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/n/nordvpn-release/nordvpn-release_1.0.0_all.deb && \
    apt-get install -y /tmp/nordrepo.deb && \
    apt-get update && \
    apt-get install -y nordvpn && \
    apt-get remove -y wget nordvpn-release && \
    rm /tmp/nordrepo.deb && \
    apt-get clean
    
RUN mkdir -p /root/bin && mkdir -p /etc/wireguard
VOLUME ["/etc/wireguard","/root","/data"]

COPY src/bin/* /root/bin/

ENTRYPOINT /etc/init.d/nordvpn start && sleep 5 && (test -r /data/.nordvpn_token && cp /data/.nordvpn_token /root/ || true) && \
  ( set -e; test -n "$NORDVPN_TOKEN" || NORDVPN_TOKEN="$(cat /root/.nordvpn_token)"; nordvpn login --token "$(echo ${NORDVPN_TOKEN})" || { printf "There was a problem.\n"; exit 1; }; ) && \
  /bin/bash -c "$@"

CMD /root/bin/NordVpnToWireguard.sh
