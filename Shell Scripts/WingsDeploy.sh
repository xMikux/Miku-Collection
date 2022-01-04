#!/bin/bash

# Deploy Dynamic Wings Node Server
# Author: Efina

# Get DNS Record ID

# curl -X GET "https://api.cloudflare.com/client/v4/zones/$CFZoneID/dns_records?type=A&name=$DNSName&match=all" \
#      -H "X-Auth-Email: $Email_Name" \
#      -H "X-Auth-Key: $CFToken" \
#      -H "Content-Type: application/json"

# Setup env file

Email_Name=

## Panel ENV
Panel_URL=
Panel_Token=

## DNS ENV
Ipv4_IP=$(curl -4 -s https://icanhazip.com/)
DNSRecordID=
CFToken=
CFZoneID=
CFAccountID=
DNSName=

## HetrixTools Agent ID

HT_AgentID=

# Upgrade OS APT Packages

apt-get update
apt-get upgrade -y

# Setup DNS

curl -X PUT "https://api.cloudflare.com/client/v4/zones/${CFZoneID}/dns_records/${DNSRecordID}" \
    -H "Authorization: Bearer ${CFToken}" \
    -H "Content-Type: application/json" \
    --data '{"type":"A","name":"'"${DNSName}"'","content":"'"${Ipv4_IP}"'","ttl":1,"proxied":false}'

# Install Depend

## Make sure is on root folder

cd /root || exit

## Install Docker
curl -sSL https://get.docker.com/ | CHANNEL=stable bash

systemctl enable --now docker

# Create SSL Cert

## Using Docker Issus cert
### Need Test
docker run --rm -it \
  -v "/root/out":/acme.sh \
  --net=host \
  -e CF_Email="$Email_Name" \
  -e CF_Token="$CFToken" \
  -e CF_Account_ID="$CFAccountID" \
  -e CF_Zone_ID="$CFZoneID" \
  --issue --server letsencrypt --dns dns_cf -d "$DNSName" \
  --key-file /acme.sh/privkey.pem \
  --fullchain-file /acme.sh/fullchain.pem \
  neilpang/acme.sh

## Move cert
mkdir /etc/letsencrypt
mkdir /etc/letsencrypt/live
mkdir /etc/letsencrypt/live/$DNSName
mv /root/out/privkey.pem /etc/letsencrypt/live/$DNSName
mv /root/out/fullchain.pem /etc/letsencrypt/live/$DNSName

# Install Wings

mkdir -p /etc/pterodactyl
curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
chmod u+x /usr/local/bin/wings

# Deploy Wings Node Config

cd /etc/pterodactyl && sudo wings configure --panel-url "$Panel_URL" --token "$Panel_Token" --node 6
cd ~ || exit

# Setup Systemd

cat <<EOM >/etc/systemd/system/wings.service
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOM

systemctl enable --now wings

# Setup Firewall

ufw allow 2022/tcp
ufw allow 8080/tcp
ufw allow 33333/tcp

# Disable PasswordAuthentication

sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/1' /etc/ssh/sshd_config
systemctl restart sshd

# Install HetrixTools Agent

wget https://raw.github.com/hetrixtools/agent/master/hetrixtools_install.sh && bash hetrixtools_install.sh $HT_AgentID 0 0 0 0 0 0

# Reboot Server to Upgrade

sleep 5s
reboot now
