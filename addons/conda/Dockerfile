# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

ARG PY_BUILD_IMAGE=ghcr.io/marco-cefetmg/selkies/py-build:main
ARG WEB_IMAGE=ghcr.io/marco-cefetmg/selkies/selkies-web-core:main
FROM ${PY_BUILD_IMAGE} AS selkies-build
FROM ${WEB_IMAGE} AS selkies-web-core
FROM quay.io/condaforge/miniforge3:latest

# Version for Conda
ARG PKG_VERSION=0.0.0
# Version for prebuilt Python package
ARG PYPI_PACKAGE=selkies
ARG PACKAGE_VERSION=0.0.0.dev0

# Use BUILDAH_FORMAT=docker in buildah
SHELL ["/bin/bash", "-c"]

# Add Conda build configuration
ARG SELKIES_BUILD=/opt/selkies-build
ADD build ${SELKIES_BUILD}

# Obtain Python application and web interface
ARG SELKIES_SOURCE=/opt/selkies-source
COPY --from=selkies-build /opt/pypi/dist/${PYPI_PACKAGE}-${PACKAGE_VERSION}-py3-none-any.whl ${SELKIES_SOURCE}/
COPY --from=selkies-web-core /usr/share/nginx/html ${SELKIES_SOURCE}/selkies-web-core

WORKDIR /opt

RUN ls -al /opt/selkies-source/* | tee -a /root/debug.txt && cat /root/debug.txt
RUN ls -al /opt/selkies-build/* | tee -a /root/debug.txt && cat /root/debug.txt

# Configure conda solver to use libmamba
RUN . /opt/conda/bin/activate && \
    conda config --set solver libmamba

# Install build tools, build local package, and pack environment using cache mounts
RUN --mount=type=cache,target=/opt/conda/pkgs \
    --mount=type=cache,target=/root/.cache/conda \
    . /opt/conda/bin/activate && \
    conda install -c conda-forge -y conda-build conda-pack && \
    SELKIES_VERSION="${PKG_VERSION}" conda-build --no-test -c conda-forge -c nvidia "${SELKIES_BUILD}" && \
    conda create -n selkies -y --use-local -c conda-forge -c nvidia selkies && \
    conda-pack -f -n selkies --arcroot selkies -o /opt/selkies-conda.tar.gz --format tar.gz --compress-level 7 -j -1 && \
    conda search --use-local "*"
#    conda-build purge-all && \
#    conda clean --tarballs --index-cache -f -y
    
# RUN . /opt/conda/bin/activate && \
#     conda install -c conda-forge -y conda-build conda-pack && \
#     SELKIES_VERSION="${PKG_VERSION}" conda-build -c conda-forge -c nvidia "${SELKIES_BUILD}" && \
#     conda create -n selkies -y --use-local -c conda-forge -c nvidia selkies && \
#     conda-pack -f -n selkies --arcroot selkies -o /opt/selkies-conda.tar.gz --format tar.gz --compress-level 7 -j -1 && \
#     conda-build purge-all && conda clean --all -f -y
