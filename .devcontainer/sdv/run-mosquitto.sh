#********************************************************************************
#* Copyright (c) 2021 Contributors to the Eclipse Foundation
#*
#* See the NOTICE file(s) distributed with this work for additional
#* information regarding copyright ownership.
#*
#* This program and the accompanying materials are made available under the
#* terms of the Eclipse Public License 2.0 which is available at
#* http://www.eclipse.org/legal/epl-2.0
#*
#* SPDX-License-Identifier: EPL-2.0
#********************************************************************************/

export HTTP_PROXY=${HTTP_PROXY}
export HTTPS_PROXY=${HTTPS_PROXY}
export NO_PROXY=${NO_PROXY}

#Terminate existing running VAL services
RUNNING_CONTAINER=$(docker ps | grep "eclipse-mosquitto" | awk '{ print $1 }')
ROOT_DIRECTORY=$(git rev-parse --show-toplevel)
MOSQUITTO_VERSION=$(cat $ROOT_DIRECTORY/.devcontainer/sdv/settings.json | jq .mosquitto.version | tr -d '"')

if [ -n "$RUNNING_CONTAINER" ];
then
    docker container stop $RUNNING_CONTAINER
fi
docker run -d -p 1883:1883 -p 9001:9001 eclipse-mosquitto:$MOSQUITTO_VERSION
