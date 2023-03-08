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
echo Please enter backup to restore without .tar.gz
read envname

ENV_FILE="magento/envs/$envname.env"
DB_NAME="magento_$envname"
USER_NAME="magento_$envname"

if test -f "$ENV_FILE"; then
    echo "$ENV_FILE already exists!"
    exit 1
fi

# untar backup
tar -xvf backups/$envname.tar.gz

# restore db
source backups/$envname/$envname.env

# Create SQL command to create new user with password
SQL_USER_COMMAND="CREATE USER '${USER_NAME}'@'172.50.1.%' IDENTIFIED BY '${MARIADB_PASSWORD}';"

SQL_DB_COMMAND="CREATE DATABASE ${DB_NAME};"

# Create SQL command to grant privileges to new user on the specified database
SQL_GRANT_COMMAND="GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${USER_NAME}'@'172.50.1.%';"

# Execute SQL commands using MySQL client
mysql -u root -h ${SQL_HOST} -p${MARIADB_ROOT_PASSWORD} -e "${SQL_USER_COMMAND} "
mysql -u root -h ${SQL_HOST} -p${MARIADB_ROOT_PASSWORD} -e "${SQL_DB_COMMAND} ${SQL_GRANT_COMMAND} FLUSH PRIVILEGES;"

mysql -u root -h ${SQL_HOST} -p${MARIADB_ROOT_PASSWORD} --database=$DB_NAME < backups/$envname/magento_$envname.sql

# restore magento data
rm -rf $DOCKER_VOLUMES/${envname}_magento_data/
mkdir -p $DOCKER_VOLUMES/${envname}_magento_data/_data
cp -r backups/$envname/magento/ $DOCKER_VOLUMES/${envname}_magento_data/_data/

# restore env file
cp backups/$envname/$envname.env magento/envs/

echo "kthxbai"
