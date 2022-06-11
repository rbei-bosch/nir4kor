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


ROOT_DIRECTORY=$(git rev-parse --show-toplevel)
DATABROKER_VERSION=$(cat $ROOT_DIRECTORY/.devcontainer/sdv/settings.json | jq .databroker.version | tr -d '"')

if [[ `uname -m` == 'aarch64' ]]; then
    echo "Detected ARM architecture"
    PROCESSOR="aarch64"
    DATABROKER_EXEC_PATH="$ROOT_DIRECTORY/.devcontainer/sdv/assets/databroker/$DATABROKER_VERSION/$PROCESSOR/target/aarch64-unknown-linux-gnu/release"
else
    echo "Detected x86_64 architecture"
    PROCESSOR="x86_64"
    DATABROKER_EXEC_PATH="$ROOT_DIRECTORY/.devcontainer/sdv/assets/databroker/$DATABROKER_VERSION/$PROCESSOR/target/release"
fi

$DATABROKER_EXEC_PATH/vehicle-data-cli
