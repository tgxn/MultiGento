#!/bin/bash

docker compose up -d phpmyadmin haproxy

docker compose up -d master

docker compose up -d node1 node2

# docker compose logs master haproxy node1 -f