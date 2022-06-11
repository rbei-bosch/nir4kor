#!/usr/bin/env bash
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

echo "## Set execution flag to the files"
find /tmp/proxy-script/ -type f -iname "*.sh" -exec chmod +x {} \;
find /tmp/library-scripts/ -type f -iname "*.sh" -exec chmod +x {} \;
find /tmp/sdv/ -type f -iname "*.sh" -exec chmod +x {} \;

echo "#######################################################"
echo "### Checking proxies                                ###"
echo "#######################################################"
/tmp/proxy-script/configure-proxies.sh

echo "#######################################################"
echo "### Executing common-debian.sh                      ###"
echo "#######################################################"
yes | /tmp/library-scripts/common-debian.sh 2>&1 | tee -a /usr/local/share/common-debian.log

echo "#######################################################"
echo "### Executing docker-in-docker-debian.sh            ###"
echo "#######################################################" 
yes | /tmp/library-scripts/docker-in-docker-debian.sh 2>&1 | tee -a /usr/local/share/docker-in-docker-debian.log

echo "#######################################################"
echo "### Executing container-set.sh                      ###"
echo "#######################################################"
/tmp/sdv/container-set.sh 2>&1 | tee -a /usr/local/share/container-set.log

echo "#######################################################"
echo "### Executing add-powershell.sh                     ###"
echo "#######################################################"
/tmp/sdv/add-powershell.sh 2>&1 | tee -a /usr/local/share/add-powershell.log

echo "#######################################################"
echo "### Executing add-dapr.sh                           ###"
echo "#######################################################"
/tmp/sdv/add-dapr.sh 2>&1 | tee -a /usr/local/share/add-dapr.log

echo "#######################################################"
echo "### Executing add-nodejs.sh                         ###"
echo "#######################################################"
/tmp/sdv/add-nodejs.sh 2>&1 | tee -a /usr/local/share/add-nodejs.log

echo "#######################################################"
echo "### Executing add-python.sh                         ###"
echo "#######################################################"
/tmp/sdv/add-python.sh 2>&1 | tee -a /usr/local/share/add-python.log
