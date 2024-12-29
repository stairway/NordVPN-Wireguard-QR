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

RUN adduser --disabled-password --gecos "" nord && \
    usermod -aG nordvpn nord && \
    echo "nord ALL=NOPASSWD: ALL" > /etc/sudoers.d/nord && \
    mkdir -p /etc/wireguard && \
    chown -R nord:nord /etc/wireguard

# TODO: The 'nord ALL=NOPASSWD: ALL' line in /etc/sudoers.d/nord shouldn't be required if the below exists
RUN cat <<EOF >>/etc/sudoers.d/nord
nord ALL=(ALL) NOPASSWD: /usr/bin/nordvpn login
nord ALL=(ALL) NOPASSWD: /usr/bin/nordvpn connect
nord ALL=(ALL) NOPASSWD: /usr/bin/nordvpn d
nord ALL=(ALL) NOPASSWD: /etc/init.d/nordvpn start
nord ALL=(ALL) NOPASSWD: /etc/init.d/nordvpn stop
nord ALL=(ALL) NOPASSWD: /etc/init.d/nordvpn restart
EOF

COPY --chown=nord:nord src/ /home/nord/

VOLUME ["/etc/wireguard","/home/nord"]

USER nord

ENTRYPOINT sudo /etc/init.d/nordvpn start && sleep 5 && (test -r /data/.nordvpn_token && cp /data/.nordvpn_token /home/nord/ || true) && \
    ( set -e; test -n "$NORDVPN_TOKEN" || NORDVPN_TOKEN="$(cat /home/nord/.nordvpn_token)"; \
        nordvpn login --token "$(echo ${NORDVPN_TOKEN})" || { printf "There was a problem.\n"; exit 1; }; ) && \
    cd ~ && /bin/bash -c "$@" && nordvpn logout --persist-token

CMD sh -c '/home/nord/bin/NordVpnToWireguard.sh; ! "${DEBUG:-false}" || exec /bin/bash'
