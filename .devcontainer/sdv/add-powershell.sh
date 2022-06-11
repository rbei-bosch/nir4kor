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
echo "### Installing powershell                           ###"
echo "#######################################################"
# Install pre-requisite packages.
sudo apt-get update
sudo apt-get install -y wget apt-transport-https software-properties-common

# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O .sdv/tmp/packages-microsoft-prod.deb
sudo dpkg -i .sdv/tmp/packages-microsoft-prod.deb

# Update the list of packages after we added packages.microsoft.com
sudo apt-get update
sudo apt-get install -y powershell

rm -f .sdv/tmp/packages-microsoft-prod.deb

pwsh -Command "Set-PSRepository PSGallery -InstallationPolicy Trusted; Install-Module Pester"
