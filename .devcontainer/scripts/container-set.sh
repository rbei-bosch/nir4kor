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
echo "### Checking container creation                     ###"
echo "#######################################################"

echo "## checking if user 'vscode' was created by common-debian.sh"
if id -u vscode > /dev/null 2>&1; then
    echo "## found existing user 'vscode'"
else
    echo "## WARNING: failed to find user 'vscode'. Adding user 'vscode' directly as a fallback"
    useradd vscode --password vscode -m
    apt-get install sudo
    usermod -aG sudo vscode
    sleep 5
fi
