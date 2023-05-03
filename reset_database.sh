#!/bin/bash

cd $(dirname $(realpath $0))

echo "Stopping mysql.."
docker compose stop mysql-sdr
docker compose rm -f mysql-sdr
echo "Removing database.."
docker volume rm $(docker compose config --format json | jq -r .volumes.mysql_sdr_data.name)
echo "Restarting.."
docker compose up -d mysql-sdr
