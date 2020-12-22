#!/usr/bin/env bash

set -o errexit
set -o nounset

source configuration.env
directory=${PWD}/gatling
# mkdir gatling
# git clone ${Repository}
# sleep 60

projectDirectory=$(find $directory -mindepth 1 -maxdepth 1 -type d | awk -F/ '{print $NF}')

GATLING_RESOURCE='gatling//'${projectDirectory}'//src/test/resources'
GATLING_TEST='gatling.'${SimulationTest}''
GATLING_RESULTS='gatling//'{$projectDirectory}'/target'
GATLING_SIMULATION='gatling//'${projectDirectory}'//src//test//scala//gatling'
GATLING_LOGS='gatling//'${projectDirectory}'//log'
GATLING_LOGBACK='logback//'${LogbackFile}
GATLING_INFLUX_CONFIG='gatling-config//gatling.conf'

echo "==> Prepare Configurations"
sed -i 's/%GATLING_TEST_PATH%/'${GATLING_TEST}'/g' \
    -i 's/%GATLING_CONFIG_PATH%/'${GATLING_RESOURCE}'/g' \
    -i 's/%GATLING_LOGBACK_PATH%/'${GATLING_LOGBACK}'/g' \
    -i 's/%GATLING_INFLUX_CONFIG_PATH%/'${GATLING_INFLUX_CONFIG}'/g'   \
    -i 's/%GATLING_SIMULATION_TEST_PATH%/'${GATLING_SIMULATION}'/g'   \
    -i 's/%GATLING_SIMULATION_RESULTS_PATH%/'${GATLING_RESULTS}'/g'   \
    -i 's/%GATLING_LOGS_PATH%/'${GATLING_LOGS}'/g'   \
    templates/container.yaml.template \
  > docker-compose.yml

echo "==> Docker Image Pull"
#docker-compose pull

echo "==> Bring Up Services"
#docker-compose up gatling

echo "==> Waiting for Services Ready"
#sleep 60

# echo "==> Initial Database"
# docker exec -it influxdb                 \
#   influx                                 \
#     -username ${INFLUXDB_ADMIN_USER}     \
#     -password ${INFLUXDB_ADMIN_PASSWORD} \
#     -execute 'CREATE DATABASE '${INFLUXDB_DEMO_DATABASE}';'

# echo "==> Done"

# echo "==> Next Step:"
# echo "    Setup your dashboard by visiting http://localhost:3000"
# echo "==> Default Username: admin"
# echo "==> Default Password: admin"
