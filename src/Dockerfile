# syntax=docker/dockerfile:1.2

FROM python:3.9-slim-bullseye as base

# Build stage, to create a Virtual Environent
FROM base as builder

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y binutils

ADD ./* /
ADD ./run/secrets/* /run/secrets/

RUN python3 -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

RUN cat /run/secrets/github_token

RUN --mount=type=secret,id=github_token credential=$(cat /run/secrets/github_token); apt-get install -y git \
    && /opt/venv/bin/python3 -m pip install --upgrade pip \
    && pip3 install --no-cache-dir -r requirements.txt \
    && pip3 install --no-cache-dir git+https://${credential}@github.com/SoftwareDefinedVehicle/sdv-vehicle-app-python-sdk.git@v0.1.9

RUN pip3 install pyinstaller
RUN pyinstaller run.py -F
RUN pip3 install staticx && pip3 install patchelf
WORKDIR /dist
RUN staticx run run-exe

# Runner stage, to copy in the virtual environment and the app
#FROM debian:bullseye-slim
FROM scratch

COPY --from=builder ./dist/run-exe /dist/

WORKDIR /tmp
WORKDIR /dist
ENV PATH="/dist:$PATH"

LABEL org.opencontainers.image.source="https://github.com/softwaredefinedvehicle/vehicle-app-python-template"

CMD ["./run-exe"]