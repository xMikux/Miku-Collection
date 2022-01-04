#!/bin/bash 

trap cleanup INT TERM

echo "***Starting"

cleanup() {
    echo "***Stopping"
    exit
}

cp etc/hetrixtools_dl/hetrixtools_install_cp.sh etc/hetrixtools_dl/hetrixtools_install.sh
echo "***Copied hetrixtools_install_cp.sh to hetrixtools_install.sh"

chmod 777 etc/hetrixtools_dl/hetrixtools_install.sh
echo "***Set file permissions"

chown root etc/hetrixtools_dl/hetrixtools_install.sh
echo "***Set file owners"

chmod u+r+x etc/hetrixtools_dl/hetrixtools_install.sh
echo "***Set as executable"

sed -i 's+useradd hetrixtools -r -d /etc/hetrixtools -s /bin/false+addgroup -S hetrixtools \&\& adduser -S hetrixtools -G hetrixtools+g' etc/hetrixtools_dl/hetrixtools_install.sh
echo "***Change user create command"

etc/hetrixtools_dl/hetrixtools_install.sh $HETRIX_AGENT_PARAMS
echo "***Installed agent"

echo "***Starting cron"
crond start

while :; do
    tail -f /dev/null & wait ${!}
done
