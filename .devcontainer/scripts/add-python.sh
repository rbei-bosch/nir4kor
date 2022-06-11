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
echo "### Installing OS updates                           ###"
echo "#######################################################"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y wget ca-certificates

echo "#######################################################"
echo "### Installing python version 3                     ###"
echo "#######################################################"
ROOT_DIRECTORY=$(git rev-parse --show-toplevel)
PYTHON_VERSION=$(cat $ROOT_DIRECTORY/prerequisite_settings.json | jq .python.version | tr -d '"')

sudo apt-get install -y python3-distutils
sudo apt-get install -y python$PYTHON_VERSION
curl -fsSL https://bootstrap.pypa.io/get-pip.py | sudo python$PYTHON_VERSION

sudo update-alternatives --install /usr/bin/python python /usr/bin/python$PYTHON_VERSION 10
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python$PYTHON_VERSION 10

pip3 install pytest pytest-cov coverage2clover
pip3 install pytest-asyncio
pip3 install -U flake8
pip3 install -U pylint
pip3 install -U mypy
