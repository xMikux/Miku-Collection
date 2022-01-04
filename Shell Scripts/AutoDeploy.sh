#!/bin/bash

# Auto Deploy Instances
# Author: Efina

# Crontab setting

# 0 12 * * 6 /home/$user$/AutoDeploy.sh > /dev/null 2>&1

# Vultr Token

Vultr_Token=""

# Instance Settings

ServerName=
ScriptID=
FirewallID=

# Unknow reason, this vaule is using array of strings
# Manual using scripts to add ssh key
# SSHID=[""]
# "sshkey_id" : '$SSHID',

Region=
Plan=
OS=

# Create Instance

curl "https://api.vultr.com/v2/instances" \
  -X POST \
  -H "Authorization: Bearer ${Vultr_Token}" \
  -H "Content-Type: application/json" \
  --data '{
    "region" : "'$Region'",
    "plan" : "'$Plan'",
    "os_id" : "'$OS'",
    "ddos_protection" : true,
    "firewall_group_id" : "'$FirewallID'",
    "script_id" : "'$ScriptID'",
    "label" : "'$ServerName'",
    "hostname": "'$ServerName'"
  }'
