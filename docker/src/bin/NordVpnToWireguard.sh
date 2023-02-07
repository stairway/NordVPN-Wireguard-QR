#!/bin/bash

COUNTRY="${COUNTRY}"
CITY="${CITY}"
VERSION="0.1.0"

while [ "$1" != "" ] ; do
   case $1 in
    -v | --version )
        echo "Wireguard Config Files for NordVPN v$VERSION"
    exit
        ;;
    -c | --country )
        shift
        [ -n "$1" ] && COUNTRY="$1"
        ;;
    -s | --city )
        shift
        [ -n "$1" ] && CITY="$1"
        ;;
    -h | --help )
         cat <<EOF
Usage: NordVpnToWireguard [OPTIONS]
OPTION includes:
   -v | --version  - prints out version information.
   -c | --country  - Country to connect to (ex. Canada). If option is not provided, NordVPN will get a wireguard configuration for the recommended country, unless a valid city name is provided.
   -s | --city - City to connect to (ex. Toronto). When country option is provided, NordVPN will look for the the city within the country and return the fastest server. If no country is provided, NordVPN will look up the fastest server for a city matching the name.
   -h | --help     - displays this message.
EOF
         exit
      ;;
    * )
         cat <<EOF
Invalid option: $1
Usage: NordVpnToWireguard [-v] [-c country] [-s server]
   -v | --version   - prints out version information.
   -c | --country   - country name
   -s | --city      - city name
   -h | --help      - displays this message.
EOF
         exit
      ;;
  esac
  shift
done

if [[ -z "$COUNTRY" ]] && [[ -z "$CITY" ]] ; then
    echo "Getting configuration for recommended server..."
else
    if [[ -z "$CITY" ]] && [[ ! -z "$COUNTRY" ]] ; then
        echo "Getting configuration for recommended server in $COUNTRY"
    fi

    if [[ ! -z "$CITY" ]] && [[ -z "$COUNTRY" ]] ; then
        echo "Getting configuration for recommended server in $CITY"
    fi

    if [[ ! -z "$CITY" ]] && [[ ! -z "$COUNTRY" ]] ; then
        echo "Getting configuration for recommended server in $COUNTRY, city: $CITY"
    fi
fi

# Connect to NordVPN
printf "Connecting ...\n"
printf "\033[96;1m%s\033[0m\n" "nordvpn c $COUNTRY $CITY"
nordvpn c $COUNTRY $CITY > /dev/null 2>&1

if [ $? -ne 0 ] ; then
    echo "Unable to connect to NordVPN."
    exit 1
fi

# Preparing the Interface section
echo "[Interface]" > Nordvpn.conf
privateKey=`wg show nordlynx private-key`
echo "PrivateKey = $privateKey" >> Nordvpn.conf
echo "ListenPort = 51820" >> Nordvpn.conf
localAddress=`ifconfig nordlynx | grep inet |  awk -v OFS='\n' '{ print $2 }'`
echo "Address = $localAddress/32" >> Nordvpn.conf
echo "DNS = 103.86.96.100, 103.86.99.100" >> Nordvpn.conf
echo "" >> Nordvpn.conf

# Gathering info for the Peer section
curl -s "https://api.nordvpn.com/v1/servers/recommendations?&filters\[servers_technologies\]\[identifier\]=wireguard_udp&limit=1"|jq -r '.[]|.hostname, .station, (.locations|.[]|.country|.city.name), (.locations|.[]|.country|.name), (.technologies|.[].metadata|.[].value), .load' >> Peer.txt

# Disconnect from NordVPN
nordvpn d > /dev/null 2>&1

# Preparing the Peer section 
endpoint=`grep -m 1 -o '.*' Peer.txt | tail -n 1`
publicKey=`grep -m 5 -o '.*' Peer.txt | tail -n 1`

rm Peer.txt

echo "[Peer]" >> Nordvpn.conf
echo "PublicKey = $publicKey" >> Nordvpn.conf
echo "AllowedIPs = 0.0.0.0/0" >> Nordvpn.conf
echo "Endpoint = $endpoint:51820" >> Nordvpn.conf
echo "PersistentKeepalive = 25" >> Nordvpn.conf

# Renaming config file to show the endpoint country id and server number
outputFileName=`echo $endpoint |  grep -o '^[^.]*'`
outputFileName=`echo "NordVPN-$outputFileName.conf"`

mv Nordvpn.conf /etc/wireguard/$outputFileName
chmod 600 /etc/wireguard/$outputFileName

echo "Wireguard configuration file /etc/wireguard/$outputFileName created successfully!"

qrencode -t ansiutf8 < "/etc/wireguard/${outputFileName}"
qrencode -t ansiutf8 < "/etc/wireguard/${outputFileName}" > "/etc/wireguard/${outputFileName}.qr"

chmod 600 "/etc/wireguard/$outputFileName.qr"

exit 0