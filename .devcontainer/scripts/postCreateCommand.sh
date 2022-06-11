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

chmod +x .devcontainer/scripts/*.sh
sudo chown -R $(whoami) $HOME

echo "#######################################################"
echo "### Checking proxies                                ###"
echo "#######################################################"
sudo .devcontainer/scripts/configure-proxies.sh | tee -a $HOME/configure-proxies.log

echo "#######################################################"
echo "### Install Jq                                      ###"
echo "#######################################################"
apt-get install -y jq

echo "#######################################################"
echo "### Executing container-set.sh                      ###"
echo "#######################################################"
.devcontainer/scripts/container-set.sh 2>&1 | tee -a $HOME/container-set.log

echo "#######################################################"
echo "### Executing add-python.sh                         ###"
echo "#######################################################"
.devcontainer/scripts/add-python.sh 2>&1 | tee -a $HOME/add-python.log

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
