#!/usr/bin/env bash

set -o errexit
set -o nounset

source configuration.env
directory=${PWD}/gatling
mkdir gatling
cd gatling
git clone ${Repository}
cd ..
sleep 10

projectDirectory=$(find $directory -mindepth 1 -maxdepth 1 -type d | awk -F/ '{print $NF}')

#Configure gatling simulation class
GATLING_TEST='gatling.'${SimulationTest}''

#Configure Influx db SetUp
INFLUXDB_ADMIN_USER='admin'
INFLUXDB_ADMIN_PASSWORD='admin'
INFLUXDB_DEMO_DATABASE='graphite'

echo "==> Prepare Configurations"
sed -e 's/%GATLING_TEST_PATH%/'${GATLING_TEST}'/g' \
    -e 's/%GATLING_LOGBACK_PATH%/'${LogbackFile}'/g' \
    -e 's/%GATLING_DIRECTORY%/'${projectDirectory}'/g' \
    templates/container.yaml.sh.template \
  > docker-compose.yml

echo "==> Docker Image Pull"
docker-compose pull

echo "==> Bring Up Services"
docker-compose up -d

echo "==> Waiting for Services Ready"
sleep 60

echo "==> Initial Database"
docker exec -it influxdb                 \
  influx                                 \
    -username ${INFLUXDB_ADMIN_USER}     \
    -password ${INFLUXDB_ADMIN_PASSWORD} \
    -execute 'CREATE DATABASE '${INFLUXDB_DEMO_DATABASE}';'

echo "==> Done"

echo "==> Next Step:"
echo "    Setup your dashboard by visiting http://localhost:3000"