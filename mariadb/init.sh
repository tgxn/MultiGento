#!/bin/bash

# DB HOST
SQL_HOST="127.0.0.1"

# Source the .env file to load the password variable
source .env

# Create SQL command to create new user
SQL_HAPROXY_COMMAND="CREATE USER haproxy@172.50.0.100; FLUSH PRIVILEGES;"

# Execute SQL commands using MySQL client
mysql -u root -h ${SQL_HOST} -p${MARIADB_ROOT_PASSWORD} -e "${SQL_HAPROXY_COMMAND}"
