#!/bin/bash

# DB HOST
SQL_HOST="127.0.0.1"
CONTAINER_SQL_HOST="172.50.1.10"

# Source the .env file to load the password variable
source mariadb/.env

# GET ENV NAME
echo Please enter name for new environment
read envname

ENV_FILE="magento/envs/$envname.env"
DB_NAME="magento_$envname"
USER_NAME="magento_$envname"

MAG_HOSTNAME=$envname.aws.tgxn.net

# Set variables for database name, new username, and password
NEW_USER_PASSWORD=`date +%s | sha256sum | base64 | head -c 32 ; echo`

if test -f "$ENV_FILE"; then
    echo "$ENV_FILE already exists!"
    exit 1
fi

# Create SQL command to create new user with password
SQL_USER_COMMAND="CREATE USER '${USER_NAME}'@'172.50.1.%' IDENTIFIED BY '${NEW_USER_PASSWORD}';"

SQL_DB_COMMAND="CREATE DATABASE ${DB_NAME};"

# Create SQL command to grant privileges to new user on the specified database
SQL_GRANT_COMMAND="GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${USER_NAME}'@'172.50.1.%';"

# Execute SQL commands using MySQL client
mysql -u root -h ${SQL_HOST} -p${MARIADB_ROOT_PASSWORD} -e "${SQL_USER_COMMAND} ${SQL_DB_COMMAND} ${SQL_GRANT_COMMAND} FLUSH PRIVILEGES;"

cat << EOF > $ENV_FILE
# env deets
COMPOSE_PROJECT_NAME=$envname
MAGENTO_HOST=$MAG_HOSTNAME

# database host
MAGENTO_DATABASE_HOST=$CONTAINER_SQL_HOST
MAGENTO_DATABASE_NAME=$DB_NAME
MAGENTO_DATABASE_USER=$USER_NAME

# database password
MARIADB_PASSWORD=$NEW_USER_PASSWORD

# magento settings
MAGENTO_USERNAME=admin
MAGENTO_PASSWORD=e9op4ctjmuhw4895vyt
MAGENTO_MODE=production

ES_TAG=7.17.9
MAGENTO_TAG=2.4.5-p1
VARNISH_TAG=stable
EOF

cd magento
docker compose --env-file ./envs/$envname.env up -d

echo "kthxbai"
