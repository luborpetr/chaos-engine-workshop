#!/bin/bash


SCRIPT_LOCATION=$(readlink -f $(dirname $0))

docker run --rm -d -p 8089:8089 --volume $SCRIPT_LOCATION:/tmp/ -it  locustio/locust:latest locust -f /tmp/load_scenario.py