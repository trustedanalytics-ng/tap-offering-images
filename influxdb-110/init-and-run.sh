#!/usr/bin/env bash
#
# Copyright (c) 2016 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

TIMEOUT=15
INFLUX_URL="http://localhost:8086"
GREP_HTTP_OK="^HTTP/.\.. 200 OK"

function stopWithFail {
  echo $2
  kill -TERM $1
  exit 1
}

echo "Starting Influx on loopback interface."

INFLUXDB_ADMIN_BIND_ADDRESS="127.0.0.1:8083" \
INFLUXDB_HTTP_BIND_ADDRESS="127.0.0.1:8086" \
INFLUXDB_BIND_ADDRESS="127.0.0.1:8088" \
INFLUXDB_UDP_BIND_ADDRESS="127.0.0.1:8089" \
influxd &

INFLUX_PID=$!

echo "Waiting for Influx (PID: $INFLUX_PID)."

TIMER=0
until $(curl --silent --fail --output /dev/null $INFLUX_URL/ping); do
  printf '.'
  if [ $TIMER -eq $TIMEOUT ]; then
    stopWithFail $INFLUX_PID "Influx failed to start in $TIMEOUT seconds. Exiting..."
  fi
  sleep 1
  ((++TIMER))
done

echo "Influx available (PID=$INFLUX_PID)."

echo "Initializing user"
if [ -z "`curl -sli $INFLUX_URL/query --data-urlencode \"q=CREATE USER $INFLUXDB_USERNAME WITH PASSWORD '$INFLUXDB_PASSWORD' WITH ALL PRIVILEGES\" | grep \"$GREP_HTTP_OK\"`" ]; then
  stopWithFail $INFLUX_PID "Cannot create user. Exiting..."
else
  echo "Created user with all privileges."
fi

echo "Initialization completed. Restarting Influx on proper interface."

TIMER=0
until [ ! $(kill -TERM $INFLUX_PID) ]; do
  printf '.'
  if [ $TIMER -eq $TIMEOUT ]; then
    echo "Influx failed to stop in $TIMEOUT seconds. Exiting..."
    kill -KILL $INFLUX_PID
    wait $INFLUX_PID
    exit 1
  fi
  sleep 1
  ((++TIMER))
done

wait $INFLUX_PID

echo "Influx stopped. Starting new Influx process."

exec influxd
