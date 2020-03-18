#!/bin/bash

#Start and provision XMPP test server

docker run -it --rm -d --name ejabberd  \
    -p 5222:5222 \
    -p 5269:5269 \
    -p 5443:5443 \
    -p 1883:1883 \
    -p 5280:5280 ejabberd/ecs


docker exec -it ejabberd bin/ejabberdctl register test localhost test
docker exec -it ejabberd bin/ejabberdctl register chaos localhost test
