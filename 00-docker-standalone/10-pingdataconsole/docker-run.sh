#!/bin/sh
if test -z "$(docker network ls --filter name=pingnet -q)" ; then
	docker network create pingnet
fi

CONTAINER_NAME=pingdataconsole
if test -z "$(docker container ls --filter name=${CONTAINER_NAME} -q)" ; then
	if test -z "$(docker container ls -a --filter name=${CONTAINER_NAME} -q)" ; then
		docker run -d --network pingnet -p 8080:8080 --name pingdataconsole pingidentity/pingdataconsole
	else
		docker start ${CONTAINER_NAME}
	fi
	sleep 15
else
	echo "Container ${CONTAINER_NAME} already running"
fi
open http://localhost:8080/admin-console