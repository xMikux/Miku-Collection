#!/bin/bash

# Deploy Dynamic Wings Node Server
# Author: Efina

## Please Notice!
## This Script only test on Debian OS!

# Get DNS Record ID

# curl -X GET "https://api.cloudflare.com/client/v4/zones/$CFZoneID/dns_records?type=A&name=$DNSName&match=all" \
#      -H "X-Auth-Email: $Email_Name" \
#      -H "X-Auth-Key: $CFToken" \
#      -H "Content-Type: application/json"

# Server Settings

# Update DNS
DNS_Update=True
RANDOM_SRV_DNS=False

# Security Settings

MinecraftPortList=
MineWall_Enable=False

# Network Optimization

BBR_Enable=False

# Setup env var

Email_Name=

## Panel ENV
Panel_URL=
Panel_Token=

## DNS ENV
IPV4_IP=$(curl -4 -s https://icanhazip.com/)
DNSRecordID=
CFToken=
CFZoneID=
CFAccountID=
DNSName=

## Random SRV

RandomName=$(echo $RANDOM | md5sum | head -c 6).
RANDOM_SRVID=
RANDOM_SRVName=$RandomName.
SRVPort=

## HetrixTools Agent

HT_Enable=False
HT_AgentID=

## Discord Webhook

DiscordWebhook_Enable=False
SubDNS=
CurrentDate=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
Discord_Webhook=""
Discord_Content=""

## SSH Key

SSH_KEY=""

# Upgrade OS APT Packages

SystemUpgrade () {
  apt-get update && apt-get upgrade -y
  cd /root || exit
}

# Update DNS & SRV

DNSUpdate () {

  # Ipv4 Updater
  if [ "$DNS_Update" = True ]; then
    echo "Update ${DNSName} to new IPv4..."
    curl -X PUT "https://api.cloudflare.com/client/v4/zones/${CFZoneID}/dns_records/${DNSRecordID}" \
        -H "Authorization: Bearer ${CFToken}" \
        -H "Content-Type: application/json" \
        --data '{"type":"A","name":"'"${DNSName}"'","content":"'"${IPV4_IP}"'","ttl":1,"proxied":false}'
    echo "Finish Update ${DNSName} DNS!"
  else
    echo "Not Enable DNS Update, Skip..."
  fi

  # Random SRV Record
  if [ "$RANDOM_SRV_DNS" = True ]; then
    echo "Update Random DNS Record ${RANDOM_SRVID}..."
    curl -X PUT "https://api.cloudflare.com/client/v4/zones/${CFZoneID}/dns_records/${RANDOM_SRVID}" \
        -H "Authorization: Bearer ${CFToken}" \
        -H "Content-Type: application/json" \
        --data '{"type": "SRV", "data": {"service": "_minecraft", "proto": "_tcp", "name": "'"$RANDOM_SRVName"'", "priority": 0, "weight": 0, "port": '$SRVPort', "target": "'"$DNSName"'"}}'
    echo "Finish Update ${RANDOM_SRVID} Random DNS Record!"
  else
    echo "Not Enable Random SRV DNS, Skip..."
  fi
}

# Install Depend

Install_PerRequiment () {

  # Docker Install
  echo "Start Install Docker"
  curl -sSL https://get.docker.com/ | CHANNEL=stable bash
  systemctl enable --now docker
  echo "Finish Install Docker!"

  # Wings Install
  mkdir -p /etc/pterodactyl
  curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
  chmod u+x /usr/local/bin/wings

  # Install HetrixTools Agent
  if [ "$HT_Enable" = True ] && [ -z "$HT_AgentID" ]; then
    echo "Install HetrixTool Agent"
    wget https://raw.github.com/hetrixtools/agent/master/hetrixtools_install.sh && bash hetrixtools_install.sh $HT_AgentID 0 0 0 0 0 0
  else
    echo "There have missing ID, or is disable."
    echo "Skip Install HetrixTools Agent..."
  fi

  # Google BBR Install
  if [ "$BBR_Enable" = True ]; then
    echo "Install BBR Optimization..."
    curl -fsSL git.io/deploy-google-bbr.sh | bash
    echo "Finish Install BBR Optimization!"
  else
    echo "Not enable BBR, Skip..."
  fi
}

# Setup Wings

Wings_Setup () {

  # Using Docker to Get SSL
  echo "Get the SSL Cert..."
  docker run --rm -it \
  -v "/root/out":/acme.sh \
  --net=host \
  -e CF_Email="$Email_Name" \
  -e CF_Token="$CFToken" \
  -e CF_Account_ID="$CFAccountID" \
  -e CF_Zone_ID="$CFZoneID" \
  neilpang/acme.sh \
  --issue --server letsencrypt --dns dns_cf -d "$DNSName" \
  --key-file /acme.sh/privkey.pem \
  --fullchain-file /acme.sh/fullchain.pem
  echo "Finish Create Cert!"

  # Make the ssl folder, and move the cert inside it
  echo "Making Folder, and move the cert inside it..." 
  mkdir -p /etc/letsencrypt/live/$DNSName
  mv /root/out/privkey.pem /etc/letsencrypt/live/$DNSName
  mv /root/out/fullchain.pem /etc/letsencrypt/live/$DNSName
  echo "Finish make, and move!"

  # Setup Wings Node Configs
  echo "Setup Wings Config..."
  cd /etc/pterodactyl && sudo wings configure --panel-url "$Panel_URL" --token "$Panel_Token" --node 6
  cd ~ || exit
  echo "Finish Setup Wings Config!"

  # Setup Wings Service
  echo "Create Wings Service..."
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
  echo "Finish Create Wings Service!"

  # Setting Wings Firewall
  echo "Setting Wings Firewall..."
  ufw allow 2022/tcp
  ufw allow 8080/tcp
  echo "Finish Setting!"

  # Enable Wings
  echo "Enable Wings Service..."
  systemctl enable --now wings
  echp "Finish enable service!"

}


# Security Settings

Security_Setup () {
  Auth_Path=/root/.ssh/authorized_keys

  if [ -z "$SSH_KEY" ]; then

    # Manual Replace SSH Key
    echo "Replace SSH Key..."
    echo "$SSH_KEY" > $Auth_Path
    echo "Replace Done!"

    # Disable Password Login Action
    echo "Disable PasswordAuth..."
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/1' /etc/ssh/sshd_config
    systemctl restart sshd
    echo "Disable PasswordAuth Done!"
  elif [ -f "$Auth_Path" ]; then
    # Disable Password Login Action
    echo "Disable PasswordAuth..."
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/1' /etc/ssh/sshd_config
    systemctl restart sshd
    echo "Disable PasswordAuth Done!"
  else
    echo "There is not value about SSH Key."
    echo "And don't have AuthKey, so skip PasswordAuth disable..."
  fi

  # Setup Firewall
  ufw allow "$MinecraftPortList"/tcp

  # Setup MineWall
  if [ "$MineWall_Enable" = True ]; then

    echo "Setup MineWall..."
    wget https://git.entryrise.com/EntryRise/MineWall/raw/branch/master/Tools/firewall.sh -P /tmp
    sed -i 's/protect_port=25565/protect_port='"$MinecraftPortList"'/1' /tmp/firewall.sh
    bash /tmp/firewall.sh
    echo "Setup Complete!"

    echo "Making Crontab for AutoUpdate Ip List"
    mkdir /root/Script
    wget https://git.entryrise.com/EntryRise/MineWall/raw/branch/master/Tools/whitelister.sh -P /root/Script
    chmod +x /root/Script/whitelister.sh
    crontab -l | { cat; echo "*/5 * * * * /root/Script/whitelister.sh"; } | crontab -
  else
    echo "MineWall is not enable, Skip..."
  fi
}

# Send Finish Webhook

Discord_Webhook_Notify () {
  if [ "$DiscordWebhook_Enable" = True ] && [ -z "$Discord_Webhook" ]; then
    curl -i \
      -H "Accept: application/json" \
      -H "Content-Type:application/json" \
      -X POST --data \
      "$Discord_Content" \
      "$Discord_Webhook"
  else
    echo "Not enable Discord Notify, Skip..."
  fi
}

# Reboot Server to Upgrade

SystemReboot () {
  echo "Finish All Script! Auto Restart Server to full upgrade server."
  echo "Restart Server in 10 sec..."
  sleep 10s
  echo "Restart!"
  reboot now
}

# Main

SystemUpgrade
DNSUpdate
Install_PerRequiment
Wings_Setup
Security_Setup
Discord_Webhook_Notify
SystemReboot
