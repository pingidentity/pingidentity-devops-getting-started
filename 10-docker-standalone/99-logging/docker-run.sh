#!/usr/bin/env sh

cd "$( dirname ${0} )"
HERE=$( pwd )
SHARED=$( cd ../FF-shared;pwd )
WS=$( cd ../../.. ; pwd )

# load the shared variables
# shellcheck source=../FF-shared/env_vars
test -f "${SHARED}/env_vars" && . "${SHARED}/env_vars"

# prepare the docker network (something all our containers have to do)
# shellcheck source=../FF-shared/prepare-network.sh.fragment
test -f "${SHARED}/prepare-network.sh.fragment" && . "${SHARED}/prepare-network.sh.fragment"

# start elastic serach
ES_CONTAINER=elasticsearch
CONTAINER_NAME=${ES_CONTAINER}
if test -z "$( docker container ls -a --filter name=${CONTAINER_NAME} -q )" ; then
  docker run -d \
    -p 9200:9200 \
    -p 9300:9300 \
    --name ${CONTAINER_NAME} \
    --network ${NETWORK_NAME} \
    -e LOGSPOUT=ignore \
    elasticsearch:1.5.2
elif test -z "$( docker container ls --filter name=${CONTAINER_NAME} -q )" ; then 
  docker start ${CONTAINER_NAME}
fi



# start kibana
CONTAINER_NAME=kibana
if test -z "$( docker container ls -a --filter name=${CONTAINER_NAME} -q )" ; then
 docker run -d \
  -p 5601:5601 \
  -e ELASTICSEARCH_URL=http://${ES_CONTAINER}:9200 \
  --network ${NETWORK_NAME} \
  --name ${CONTAINER_NAME} \
  -e LOGSPOUT=ignore \
  kibana:4.1.2 
elif test -z "$( docker container ls --filter name=${CONTAINER_NAME} -q )" ; then 
  docker start ${CONTAINER_NAME}
fi

# start logstash
CONTAINER_NAME=logstash
docker pull busybox
if ! test -z "$( docker container ls -a -q --filter name=stash_config )" ; then
  docker container rm stash_config
fi
docker create -v /config --name stash_config busybox
docker cp logstash.conf stash_config:/config/

if test -z "$( docker container ls -a --filter name=${CONTAINER_NAME} -q )" ; then
  docker run -d \
    -p 5000:5000 \
    -p 5000:5000/udp \
    --volumes-from stash_config \
    --network ${NETWORK_NAME} \
    --name ${CONTAINER_NAME} \
    -e LOGSPOUT=ignore \
    logstash:2.1.1  -f /config/logstash.conf
elif ! test -z "$( docker container ls --filter name=${CONTAINER_NAME} -q )" ; then 
  docker start ${CONTAINER_NAME}
fi

CONTAINER_NAME=logspout
ip=192.168.0.102
if test -z "$( docker container ls -a --filter name=${CONTAINER_NAME} -q )" ; then
  docker run -d \
    -v /var/run/docker.sock:/tmp/docker.sock \
    --name ${CONTAINER_NAME} \
    -e LOGSPOUT=ignore \
    -e DEBUG=true \
    --publish=$ip:8000:80 \
    gliderlabs/logspout:master syslog://$ip:5000
elif test -z "$( docker container ls --filter name=${CONTAINER_NAME} -q )" ; then 
  docker start ${CONTAINER_NAME}
fi

echo
echo
echo
echo check elastic search status at
echo curl localhost:9200/_cat/health?v
echo 
echo To check that logstash is inded getting log messages, use
echo docker logs -f logstash
echo
echo Access Kibana dashboad at
echo http://localhost:5601/
