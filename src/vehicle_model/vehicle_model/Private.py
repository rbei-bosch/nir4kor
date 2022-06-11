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

# pylint: disable=C0103

from sdv.model import Model

from vehicle_model.J1939 import J1939


class Private(Model):
    """
    A class used to represent Private model

    ...

    Attributes
    ----------
    J1939 : J1939
        an object instantiation of J1939 class
    """

    def __init__(self, parent: Model):
        super().__init__(parent)

        self.J1939 = J1939(self)
