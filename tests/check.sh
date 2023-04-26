#!/bin/bash

is_running=0
sleep_time=5
max_tries=10
pubsub_url="http://localhost:8085"
nb_success=0
expected_success=3

for i in $(seq "$max_tries")
do
  echo "## Starting check ($i/$max_tries)"

  pid="$(docker compose ps --status=running --quiet)"

  if [ $is_running == 0 ]
  then
    if [ -z "$pid" ]
    then
      echo "Still not running, trying again in $sleep_time seconds..."
      sleep $sleep_time
      continue
    fi

    is_running=1
  else
    if [ -z "$pid" ]
    then
      echo "Container was running, but not anymore, maybe it crashed?"
      echo "== Logs: ========="
      docker compose logs
      echo "=================="

      exit 255
    fi
  fi

  echo "== Container is running with version: ========="
  docker compose exec pubsub gcloud --version
  echo "==============================================="

  echo "Trying to poll the PubSub endpoint"

  output="$(curl --silent --fail --location $pubsub_url)"
  return_code=$?

  echo "== PubSub endpoint at $pubsub_url returned (code=$return_code): ========="
  echo "$output"
  echo "==============================================================================="

  if [ $return_code == 0 ] && [ "$output" == "Ok" ]
  then
    echo "Considering this as a success!"
    nb_success=$((nb_success + 1))
    echo "Successfully checked $nb_success/$expected_success."

    if [ $nb_success == $expected_success ]
    then
      echo "It ran long enough, it seems to be working!"
      exit 0
    fi

    # Check several times to be sure it's stable.
    echo "Checking once more in $sleep_time seconds"
    sleep $sleep_time
    continue
  fi

  echo "PubSub endpoint seemed to have returned an error, trying again in $sleep_time seconds..."
  sleep $sleep_time
done

echo "Didn't work successfully after $max_tries, considering it fails."
exit 255
