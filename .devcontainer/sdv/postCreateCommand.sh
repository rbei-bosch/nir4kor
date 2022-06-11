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

chmod +x .devcontainer/sdv/*.sh
sudo chown -R $(whoami) $HOME

echo "#######################################################"
echo "### Checking proxies                                ###"
echo "#######################################################"
.devcontainer/sdv/configure-proxies.sh

echo "#######################################################"
echo "### Executing container-set.sh                      ###"
echo "#######################################################"
.devcontainer/sdv/container-set.sh 2>&1 | tee -a $HOME/container-set.log

echo "#######################################################"
echo "### Executing add-python.sh                         ###"
echo "#######################################################"
.devcontainer/sdv/add-python.sh 2>&1 | tee -a $HOME/add-python.log

echo "#######################################################"
echo "### Executing add-dapr.sh                           ###"
echo "#######################################################"
.devcontainer/sdv/add-dapr.sh 2>&1 | tee -a $HOME/add-dapr.log

echo "#######################################################"
echo "### Initializing dapr                               ###"
echo "#######################################################"
dapr uninstall --all
dapr init

echo "#######################################################"
echo "### Install python testing tools                    ###"
echo "#######################################################"
pip3 install pytest pytest-cov coverage2clover
pip3 install pytest-asyncio
pip3 install -U flake8
pip3 install -U pylint
pip3 install -U mypy

echo "#######################################################"
echo "### Install python requirements                     ###"
echo "#######################################################"
REQUIREMENTS="./src/requirements-dev.txt"
if [ -f $REQUIREMENTS ]; then
    pip3 install -r $REQUIREMENTS
fi
REQUIREMENTS="./src/requirements-sdv.txt"
if [ -f $REQUIREMENTS ]; then
    pip3 install -r $REQUIREMENTS
fi
REQUIREMENTS="./src/requirements.txt"
if [ -f $REQUIREMENTS ]; then
    pip3 install -r $REQUIREMENTS
fi
REQUIREMENTS="./requirements.txt"
if [ -f $REQUIREMENTS ]; then
    pip3 install -r $REQUIREMENTS
fi

echo "#######################################################"
echo "### Install Jq                                      ###"
echo "#######################################################"
sudo apt-get install -y jq
