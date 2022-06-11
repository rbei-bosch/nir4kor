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
echo "### Installing OS updates                           ###"
echo "#######################################################"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y wget ca-certificates

echo "#######################################################"
echo "### Installing python version 3                     ###"
echo "#######################################################"
sudo apt-get install -y python3
sudo apt-get install -y python3-pip
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10
pip3 install pytest pytest-cov coverage2clover
pip3 install pytest-asyncio
pip3 install -U flake8
pip3 install -U pylint
pip3 install -U mypy
