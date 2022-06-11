# syntax=docker/dockerfile:1.2

# Build stage, to create a Virtual Environent
FROM --platform=$BUILDPLATFORM python:3.9-slim-bullseye as builder

ARG TARGETPLATFORM

RUN apt-get update && apt-get upgrade -y && apt-get install -y binutils

COPY ./src /

RUN python3 -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

RUN --mount=type=secret,id=github_token credential=$(cat /run/secrets/github_token); apt-get install -y git \
    && /opt/venv/bin/python3 -m pip install --upgrade pip \
    && pip3 install --no-cache-dir -r requirements.txt \
    && pip3 install --no-cache-dir git+https://${credential}@github.com/SoftwareDefinedVehicle/sdv-vehicle-app-python-sdk.git@v0.3.0

RUN pip3 install pyinstaller && pip3 install staticx && pip3 install patchelf

RUN pyinstaller run.py -F

WORKDIR /dist

RUN staticx run run-exe

# Runner stage, to copy in the virtual environment and the app
FROM --platform=$TARGETPLATFORM alpine:latest

COPY --from=builder ./dist/run-exe /dist/

WORKDIR /dist

ENV PATH="/dist:$PATH"

LABEL org.opencontainers.image.source="https://github.com/softwaredefinedvehicle/vehicle-app-python-template"

CMD ["./run-exe"]
