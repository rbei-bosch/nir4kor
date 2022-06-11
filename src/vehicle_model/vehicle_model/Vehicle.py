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

from sdv.model import DataPointFloat, Model

from vehicle_model.Cabin import Cabin
from vehicle_model.Private import Private


class Vehicle(Model):
    """
    A class used to represent Vehicle model

    ...

    Attributes
    ----------
    Speed : DataPointFloat
        an object instantiation of DataPointFloat class

    Private : Private
        an object instantiation of Private class

    Cabin : Cabin
        an object instantiation of Cabin class
    """

    def __init__(self):
        super().__init__()
        self.Speed = DataPointFloat("Speed", self)
        self.Private = Private(self)
        self.Cabin = Cabin(self)


vehicle = Vehicle()
