#!/bin/bash

if [[ -z $1 ]]; then
    rm -rf *.log
    docker rm -f $(docker ps -aq)
    docker compose down -v --rmi all --remove-orphans
    docker system prune -a --volumes --force
fi

for relver in 20.04 22.04; do
    if ! docker image inspect "selkies-py-build:latest" >/dev/null 2>&1; then
        for svc in web dist; do 
	        BUILDX_NO_DEFAULT_ATTESTATIONS=1 BUILDKIT_PARALLEL_LIMIT=1 docker-compose --log-level DEBUG build $svc 2>&1 | tee build_${svc}_$(date +%Y%m%d_%H%M%S).log
        done
    fi
    echo "$relver"
    BUILDX_NO_DEFAULT_ATTESTATIONS=1 BUILDKIT_PARALLEL_LIMIT=1 DISTRIB_RELEASE=$relver docker-compose --log-level DEBUG up --build test --force-recreate --remove-orphans 2>&1 | tee up_ubuntu-${relver}_$(date +%Y%m%d_%H%M%S).log
done
