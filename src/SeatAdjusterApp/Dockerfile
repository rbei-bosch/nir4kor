# syntax=docker/dockerfile:1.2

# Build stage, to create a Virtual Environent
FROM --platform=$TARGETPLATFORM python:3.9-slim-bullseye as builder

RUN apt-get update && apt-get upgrade -y && apt-get install -y binutils && apt-get install -y gcc

COPY ./src /src

RUN python3 -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

RUN /opt/venv/bin/python3 -m pip install --upgrade pip

RUN pip3 install wheel && pip3 install scons && pip3 install pyinstaller && pip3 install patchelf && pip3 install staticx

RUN --mount=type=secret,id=github_token credential=$(cat /run/secrets/github_token); apt-get install -y git \
    && pip3 install --no-cache-dir -r src/requirements.txt \
    && pip3 install --no-cache-dir git+https://${credential}@github.com/SoftwareDefinedVehicle/vehicle-app-python-sdk.git@v0.4.2

WORKDIR /src

RUN pyinstaller --clean -F -s SeatAdjusterApp/seatadjuster.py

WORKDIR /src/dist

RUN staticx seatadjuster run-exe

# Runner stage, to copy in the virtual environment and the app
FROM scratch

COPY --from=builder ./src/dist/run-exe /dist/

WORKDIR /tmp
WORKDIR /dist

ENV PATH="/dist:$PATH"

LABEL org.opencontainers.image.source="https://github.com/softwaredefinedvehicle/vehicle-app-python-template"

CMD ["./run-exe"]
