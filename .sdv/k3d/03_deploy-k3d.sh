#!/bin/bash

SITE_PACKAGES=$(python -m site --user-site)
WORKING_DIR=$(pwd)

if [ -f "./../../src/github_token.txt" ];
then
    GITHUB_TOKEN="github_token,src=github_token.txt"
else
    GITHUB_TOKEN="github_token"
fi

if [ -n "$1" ]; then
    echo "Building image with proxy configuration"
    # Build, push vehicleapi image
    pip install -r ./../../src/requirements-sdv.txt
    cd $SITE_PACKAGES/sdv/
    docker build \
    -f vehicle_api_mock/Dockerfile \
    -t sdv/vehicleapi:local \
    --build-arg HTTP_PROXY="http://host.docker.internal:3128" \
    --build-arg HTTPS_PROXY="http://host.docker.internal:3128" \
    --build-arg FTP_PROXY="http://host.docker.internal:3128" \
    --build-arg ALL_PROXY="http://host.docker.internal:3128" \
    --build-arg NO_PROXY="localhost,127.0.0.1" .

    cd $WORKING_DIR/../../src
    DOCKER_BUILDKIT=1 docker build \
    -f Dockerfile \
    --progress=plain --secret id=$GITHUB_TOKEN \
    -t sdv/seatadjuster:local \
    --build-arg HTTP_PROXY="http://host.docker.internal:3128" \
    --build-arg HTTPS_PROXY="http://host.docker.internal:3128" \
    --build-arg FTP_PROXY="http://host.docker.internal:3128" \
    --build-arg ALL_PROXY="http://host.docker.internal:3128" \
    --build-arg NO_PROXY="localhost,127.0.0.1" .

    cd $WORKING_DIR
else
    echo "Building image without proxy configuration"
    # Build, push vehicleapi image - NO PROXY
    pip install -r ./../../src/requirements-sdv.txt

    cd $SITE_PACKAGES/sdv/
    docker build -f vehicle_api_mock/Dockerfile -t localhost:12345/vehicleapi:local . --no-cache
    docker push localhost:12345/vehicleapi:local

    cd $WORKING_DIR/../../src
    DOCKER_BUILDKIT=1 docker build -f Dockerfile --progress=plain --secret id=$GITHUB_TOKEN -t localhost:12345/seatadjuster:local . --no-cache
    docker push localhost:12345/seatadjuster:local

    cd $WORKING_DIR
fi

helm uninstall sdv-chart --wait

# Deploy in Kubernetes
helm install sdv-chart ./../../deploy/helm --values ./values.yml --wait --timeout 60s --debug
