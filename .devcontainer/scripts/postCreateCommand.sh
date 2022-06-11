#!/bin/bash
# Copyright (c) 2022 Robert Bosch GmbH and Microsoft Corporation
#
# This program and the accompanying materials are made available under the
# terms of the Apache License, Version 2.0 which is available at
# https://www.apache.org/licenses/LICENSE-2.0.
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# SPDX-License-Identifier: Apache-2.0

sudo chmod +x .devcontainer/scripts/*.sh
sudo chmod +x .vscode/scripts/runtime/k3d/*.sh
sudo chmod +x .vscode/scripts/runtime/local/*.sh
sudo chown -R $(whoami) $HOME

sudo apt-get install -y jq

make setup
