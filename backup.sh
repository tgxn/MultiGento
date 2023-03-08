#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# DB HOST
SQL_HOST="127.0.0.1" # master node
CONTAINER_SQL_HOST="172.50.1.100" # haproxy host on public net

DOCKER_VOLUMES=/var/lib/docker/volumes

# Source the .env file to load the password variable
source mariadb/.env

# GET ENV NAME
echo Please enter environment name to backup
read envname

ENV_FILE="magento/envs/$envname.env"
DB_NAME="magento_$envname"
USER_NAME="magento_$envname"

BACKUP_TAR="backups/$envname.tar.gz"
BACKUP_TAR_LAST="backups/$envname.last.tar.gz"

# if backup already exists, archive it
if test -f "$BACKUP_TAR"; then
    echo "$BACKUP_TAR already exists! archiving"
    rm -f $BACKUP_TAR_LAST # remove oldest
    mv $BACKUP_TAR $BACKUP_TAR_LAST
fi

if ! test -f "$ENV_FILE"; then
    echo "$ENV_FILE doesn't exists!"
    exit 1
fi

mkdir -p backups/$envname
cp $ENV_FILE backups/$envname

mysqldump -u root  -h ${SQL_HOST} -p${MARIADB_ROOT_PASSWORD} $DB_NAME --column-statistics=0 > backups/$envname/$DB_NAME.sql

cp -r $DOCKER_VOLUMES/${envname}_magento_data/_data backups/$envname/magento
chown -R 1000:1000 backups/$envname/magento

tar -czvf $BACKUP_TAR backups/$envname
rm -rf backups/$envname

echo "kthxbai"
