#!/bin/bash

# GET Record ID
#curl -x get "https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/dns_records" \
#-h "x-auth-email:YOUR_EMAIL@gmail.com" \
#-h "x-auth-key:YOUR_GLOBAL_API_KEY" \
#-h "content-type: application/json"

# crontab
#*/2 * * * * /home/$user$/Cloudflare-DDNS-API.sh >/dev/null 2>&1

# Security Info
CFToken=

# DNS Info
ZoneID=
DNSRecordID=
DNSName=

# Get IP and Temp IP

NEW_IPV4_IP=$(curl -4 -s https://icanhazip.com/)
CURRENT_IPV4_IP=$(cat /tmp/current_ipv4.txt)

NEW_IPV6_IP=$(curl -6 -s https://icanhazip.com/)
CURRENT_IPV6_IP=$(cat /tmp/current_ipv6.txt)

# IPv4 DDNS

if [ "$NEW_IPV4_IP" = "$CURRENT_IPV4_IP" ]
    then
        echo "No Change in IPv4 Address"
    else
        curl -X PUT "https://api.cloudflare.com/client/v4/zones/${ZoneID}/dns_records/${DNSRecordID}" \
             -H "Authorization: Bearer ${CFToken}" \
             -H "Content-Type: application/json" \
             --data '{"type":"A","name":"'"${DNSName}"'","content":"'"${NEW_IPV4_IP}"'","ttl":120,"proxied":false}' > /dev/null
        echo "IPv4 Address Changed!"
        echo "$NEW_IPV4_IP" > /tmp/current_ipv4.txt
fi

# IPv6 DDNS

if [ "$NEW_IPV6_IP" = "$CURRENT_IPV6_IP" ]
    then
        echo "No Change in IPv6 Address"
    else
        curl -X PUT "https://api.cloudflare.com/client/v4/zones/${ZoneID}/dns_records/${DNSRecordID}" \
             -H "Authorization: Bearer ${CFToken}" \
             -H "Content-Type: application/json" \
             --data '{"type":"AAAA","name":"'"${DNSName}"'","content":"'"${NEW_IPV6_IP}"'","ttl":120,"proxied":false}' > /dev/null
        echo "IPv4 Address Changed!"
        echo "$NEW_IPV6_IP" > /tmp/current_ipv6.txt
fi
