#!/usr/bin/env bash

# sudo docker run -p 8083:8083 -p 8086:8086 \
# -e INFLUXDB_HTTP_AUTH_ENABLED=true \
# -e INFLUXDB_META_DIR=/var/lib/influxdb/meta \
# -e INFLUXDB_DATA_DIR=/var/lib/influxdb/data \
# -e INFLUXDB_DATA_WAL_DIR=/var/lib/influxdb/wal \
# -e INFLUXDB_HINTED_HANDOFF_DIR=/var/lib/influxdb/hh \
# -v $PWD/influxdb:/var/lib/influxdb:rw \
# influxdb:1.1.0-alpine

INFLUX_HOST="localhost"
INFLUX_PORT="8086"
INFLUX_VER="1.1"
INFLUX_DBNAME="foo"
INFLUX_POLICY="bar"

INFLUX_USER="emanresu"
INFLUX_PASS="drowssap"

function stopWithFail {
  echo $1
  exit 1
}

GREP_HTTP_OK="^HTTP/.\.. 200 OK"
GREP_HTTP_NOCONTENT="^HTTP/.\.. 204 No Content"

URI=$INFLUX_HOST:$INFLUX_PORT

if [ -z "`curl -sl -I $URI/ping | grep \"$GREP_HTTP_NOCONTENT\"`" ]; then
  stopWithFail "No Influx instance found."
else 
  echo "Influx found."
fi

if [ -z "`curl -sl -I $URI/ping | grep \"^X-Influxdb-Version: $INFLUX_VER\"`" ]; then
  stopWithFail "Invalid Influx version found."
else
  echo "Influx is in proper version $INFLUX_VER."
fi

if [ -z "`curl -sli $URI/query --data-urlencode \"q=CREATE USER $INFLUX_USER WITH PASSWORD '$INFLUX_PASS' WITH ALL PRIVILEGES\" | grep \"$GREP_HTTP_OK\"`" ]; then
  stopWithFail "Cannot create user $INFLUX_USER with password: $INFLUX_PASS."
else
  echo "Created user $INFLUX_USER with password: $INFLUX_PASS."
fi

echo "Creating Influx database."

if [ -z "`curl -sli $URI/query?u=\"$INFLUX_USER\"\&p=\"$INFLUX_PASS\" --data-urlencode \"q=CREATE DATABASE $INFLUX_DBNAME\" | grep \"$GREP_HTTP_OK\"`" ]; then
  stopWithFail "Problem with creation of $INFLUX_DBNAME database."
else
  echo "Database $INFLUX_DBNAME has been created."
fi

if [ -z "`curl -sli $URI/query?u=\"$INFLUX_USER\"\&p=\"$INFLUX_PASS\" --data-urlencode \"q=CREATE RETENTION POLICY $INFLUX_POLICY ON $INFLUX_DBNAME DURATION 300d REPLICATION 3 DEFAULT\" | grep \"$GREP_HTTP_OK\"`" ]; then
  stopWithFail "Problem with creation of $INFLUX_POLICY for $INFLUX_DBNAME database."
else
  echo "Policy $INFLUX_POLICY created for $INFLUX_DBNAME database."
fi

if [ -z "`curl -sli $URI/write?db=\"$INFLUX_DBNAME\"\&u=\"$INFLUX_USER\"\&p=\"$INFLUX_PASS\" --data-binary \"mymeas,mytag=1 myfield=91\" | grep \"$GREP_HTTP_NOCONTENT\"`" ]; then
  stopWithFail "Problem with data saving."
else
  echo "Data saved."
fi

if [ -z "`curl -sli $URI/query?db=\"$INFLUX_DBNAME\"\&u=\"$INFLUX_USER\"\&p=\"$INFLUX_PASS\" --data-urlencode \"q=SELECT * FROM \"mymeas\"\" | grep \"$GREP_HTTP_OK\"`" ]; then
  stopWithFail "Problem with data querying."
else
  echo "Data is OK."
fi

exit 0
