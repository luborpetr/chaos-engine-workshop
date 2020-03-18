#!/bin/bash

#Start and provision XMPP test server

SCRIPT_LOCATION=$(readlink -f $(dirname $0))

docker run -it --rm -d --name ejabberd  \
    -p 5222:5222 \
    -p 5269:5269 \
    -p 5443:5443 \
    -p 1883:1883 \
    -p 5280:5280 ejabberd/ecs

sleep 5

MACHINE_IP=$(SCRIPT_LOCATION/../get-ip.sh)

docker exec -it ejabberd sed -i "s/-\ localhost/-\ localhost\n\  - $MACHINE_IP/g" /home/ejabberd/conf/ejabberd.yml
docker exec -it ejabberd bin/ejabberdctl reload_config

sleep 5

docker exec  ejabberd bin/ejabberdctl register test localhost test
docker exec  ejabberd bin/ejabberdctl register chaos localhost test
