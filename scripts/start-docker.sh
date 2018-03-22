#!/bin/bash

#set -o nounset \
#    -o errexit \
#    -o verbose

# Verify jq is installed
if [[ $(type jq 2>&1) =~ "not found" ]]; then
  echo -e "\nERROR: This script requires 'jq'. Please install 'jq' and run again.\n"
  exit 1
fi

# Stop existing demo Docker containers
./scripts/stop-docker.sh

# Bring up Docker Compose
echo -e "Bringing up Docker Compose"
docker-compose up -d

# Verify Confluent Control Center has started within 120 seconds
MAX_WAIT=120
CUR_WAIT=0
while [[ ! $(docker-compose logs control-center) =~ "Started NetworkTrafficServerConnector" ]]; do
  sleep 10
  CUR_WAIT=$(( CUR_WAIT+10 ))
  if [[ "$CUR_WAIT" -gt "$MAX_WAIT" ]]; then
    echo -e "\nERROR: The logs in control-center container do not show 'Started NetworkTrafficServerConnector'. Please troubleshoot with 'docker-compose ps' and 'docker-compose logs'.\n"
    exit 1
  fi
done

echo -e "\n\nStart KSQL engine:"
docker exec kafkastreamsexamples_ksql-cli_1 ksql-server-start /tmp/ksql.properties >/tmp/ksql.log 2>&1 &
sleep 10
docker-compose exec ksql-cli ksql-cli remote http://localhost:8080 --exec "run script '/tmp/ksql.commands';"

echo -e "\n\ndocker-compose exec ksql-cli ksql-cli remote http://localhost:8080"
