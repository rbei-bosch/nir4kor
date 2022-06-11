#!/bin/bash

WORKING_DIR=$(pwd)

if [ -f "./../../github_token.txt" ];
then
    GITHUB_TOKEN="github_token,src=github_token.txt"
else
    GITHUB_TOKEN="github_token"
fi

if [ -n "$HTTP_PROXY" ]; then
    echo "Building image with proxy configuration"

    cd $WORKING_DIR/../../src
    DOCKER_BUILDKIT=1 docker build \
    -f Dockerfile \
    --progress=plain --secret id=$GITHUB_TOKEN \
    -t localhost:12345/seatadjuster:local \
    --build-arg HTTP_PROXY="$HTTP_PROXY" \
    --build-arg HTTPS_PROXY="$HTTPS_PROXY" \
    --build-arg FTP_PROXY="$FTP_PROXY" \
    --build-arg ALL_PROXY="$ALL_PROXY" \
    --build-arg NO_PROXY="$NO_PROXY" . --no-cache
    docker push localhost:12345/seatadjuster:local

    cd $WORKING_DIR
else
    echo "Building image without proxy configuration"
    # Build, push vehicleapi image - NO PROXY
    pip install -r ./../../src/requirements-sdv.txt

    cd $WORKING_DIR/../../
    DOCKER_BUILDKIT=1 docker build -f Dockerfile --progress=plain --secret id=$GITHUB_TOKEN -t localhost:12345/seatadjuster:local . --no-cache
    docker push localhost:12345/seatadjuster:local

    cd $WORKING_DIR
fi

helm uninstall sdv-chart --wait

# Deploy in Kubernetes
helm install sdv-chart ./../../deploy/helm --values ./values.yml --wait --timeout 60s --debug
