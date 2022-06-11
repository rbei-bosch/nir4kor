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
echo "#######################################################"
echo "### Running Mosquitto                               ###"
echo "#######################################################"

ROOT_DIRECTORY=$(git rev-parse --show-toplevel)
source $ROOT_DIRECTORY/.vscode/scripts/exec-check.sh "$@" $(basename $BASH_SOURCE .sh)

#Terminate existing running VAL services
RUNNING_CONTAINER=$(docker ps | grep "eclipse-mosquitto" | awk '{ print $1 }')
MOSQUITTO_VERSION=$(cat $ROOT_DIRECTORY/prerequisite_settings.json | jq .mosquitto.version | tr -d '"')

if [ -n "$RUNNING_CONTAINER" ];
then
    docker container stop $RUNNING_CONTAINER
fi
docker run -p 1883:1883 -p 9001:9001 eclipse-mosquitto:$MOSQUITTO_VERSION
