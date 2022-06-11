# syntax=docker/dockerfile:1.2

# Build stage, to create the executable
FROM --platform=$TARGETPLATFORM python:3.9-slim-bullseye as builder

RUN apt-get update && apt-get install -y binutils

COPY ./src /
COPY ./.prebuilt /prebuilt

RUN /bin/bash -c 'set -ex && \
    ARCH=`uname -m` && \
    if [ "$ARCH" == "x86_64" ]; then \
       echo "x86_64" && \
       pip3 install staticx; \
    elif [ "$ARCH" == "aarch64" ]; then \
        echo "ARM64" && \
        pip3 install /prebuilt/staticx-0.13.6-py3-none-manylinux2014_aarch64.whl; \
    else \
       echo "unknown arch"; \
    fi'


RUN --mount=type=secret,id=github_token credential=$(cat /run/secrets/github_token) \
    && pip3 install --no-cache-dir pyinstaller \
    && pip3 install --no-cache-dir patchelf \
    && pip3 install --no-cache-dir -r requirements.txt \
    && pip3 install --no-cache-dir https://${credential}@api.github.com/repos/SoftwareDefinedVehicle/vehicle-app-python-sdk/tarball/v0.4.2

RUN pyinstaller --clean -F -s run.py

WORKDIR /dist

RUN staticx run run-exe

# Runner stage, to copy the executable
FROM scratch

COPY --from=builder ./dist/run-exe /dist/

WORKDIR /tmp
WORKDIR /dist

ENV PATH="/dist:$PATH"

LABEL org.opencontainers.image.source="https://github.com/softwaredefinedvehicle/vehicle-app-python-template"

CMD ["./run-exe"]
