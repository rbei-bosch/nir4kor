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


echo "#######################################################"
echo "### Download and installing VAL services            ###"
echo "#######################################################"
./.devcontainer/sdv/run-mosquitto.sh
./.devcontainer/sdv/run-databroker.sh "run-in-background"
./.devcontainer/sdv/run-seatservice.sh "run-in-background"
