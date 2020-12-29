#!/usr/bin/env bash

echo "==> Clean up database"

#Configure Influx db SetUp
INFLUXDB_ADMIN_USER='admin'
INFLUXDB_ADMIN_PASSWORD='admin'
INFLUXDB_DEMO_DATABASE='graphite'

# docker exec -it influxdb                 \
#   influx                                 \
#     -username ${INFLUXDB_ADMIN_USER}     \
#     -password ${INFLUXDB_ADMIN_PASSWORD} \
#     -execute 'DROP DATABASE '${INFLUXDB_DEMO_DATABASE}';'

echo "==> Clean up database"
docker-compose down

echo "==> Clean influx DB volume"
docker volume rm demo_influxdb-lib

echo "==> Clean Gatling git repository"
directory=${PWD}/gatling
rm -rf $directory