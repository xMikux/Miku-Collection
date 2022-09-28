#!/bin/bash

# DB Container Backup Script Template
# ---
# This backup script can be used to automatically backup databases in docker containers.
# It currently supports mariadb, mysql and bitwardenrs containers.
#
# From: https://github.com/xcad2k/scripts
#
# 

DAYS=7
BACKUPDIR=/opt/portainer-data/database_backup


# backup all mysql/mariadb containers

CONTAINER=mariadb-local
CONTAINER_1=mariadb-external

# echo "$CONTAINER"

if [ ! -d $BACKUPDIR ]; then
    mkdir -p $BACKUPDIR
fi

for i in $CONTAINER; do
    # MYSQL_DATABASE=$(docker exec $i env | grep MYSQL_DATABASE |cut -d"=" -f2)
    MYSQL_PWD=$(docker exec $i env | grep MYSQL_ROOT_PASSWORD |cut -d"=" -f2)

    docker exec -e MYSQL_PWD="$MYSQL_PWD" \
        $i /usr/bin/mysqldump -u root --all-databases \
        | gzip > $BACKUPDIR/$i-$MYSQL_DATABASE-$(date +"%Y%m%d%H%M").sql.gz

    OLD_BACKUPS=$(ls -1 $BACKUPDIR/$i*.gz |wc -l)
    if [ $OLD_BACKUPS -gt $DAYS ]; then
        find $BACKUPDIR -name "$i*.gz" -daystart -mtime +$DAYS -delete
    fi
done

for i in $CONTAINER_1; do
    # MYSQL_DATABASE=$(docker exec $i env | grep MYSQL_DATABASE |cut -d"=" -f2)
    MYSQL_PWD=$(docker exec $i env | grep MARIADB_ROOT_PASSWORD |cut -d"=" -f2)

    docker exec -e MYSQL_PWD="$MYSQL_PWD" \
        $i /usr/bin/mysqldump -u root --all-databases \
        | gzip > $BACKUPDIR/$i-$MYSQL_DATABASE-$(date +"%Y%m%d%H%M").sql.gz

    OLD_BACKUPS=$(ls -1 $BACKUPDIR/$i*.gz |wc -l)
    if [ $OLD_BACKUPS -gt $DAYS ]; then
        find $BACKUPDIR -name "$i*.gz" -daystart -mtime +$DAYS -delete
    fi
done
