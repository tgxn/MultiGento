#!/bin/bash

docker compose stop node1 node2
docker compose rm -f node1 node2

docker compose stop master
docker compose rm -f master

# docker compose stop phpmyadmin haproxy

# docker compose down 
