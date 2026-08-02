#!/bin/bash
sudo -S -v -p '' <<<"qwe123"

# [[ "$EUID" == 0 ]] || exec sudo -s "$0" "$@"

# shopt -s expand_aliases
# alias docker=podman
# alias docker-compose=podman-compose

if [[ -z $1 ]]; then
    rm -rf *.log
    docker rm -f $(docker ps -aq)
    docker compose down -v --rmi all --remove-orphans
    docker system prune -a --volumes --force
fi

for relver in 24.04 22.04 20.04; do
    if docker image inspect "selkies-py-build:latest" >/dev/null 2>&1; then
        for svc in web dist; do 
	        BUILDX_NO_DEFAULT_ATTESTATIONS=1 BUILDKIT_PARALLEL_LIMIT=1 docker compose build $svc 2>&1 | tee build_${svc}_$(date +%Y%m%d_%H%M%S).log
        done
    fi
    echo "$relver"
    BUILDX_NO_DEFAULT_ATTESTATIONS=1 BUILDKIT_PARALLEL_LIMIT=1 BUILDAH_FORMAT=docker DISTRIB_RELEASE=$relver docker compose up --build test --force-recreate --remove-orphans 2>&1 | tee up_ubuntu-${relver}_$(date +%Y%m%d_%H%M%S).log
done
