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

"""Cabin Model"""

# pylint: disable=C0103

from sdv.model import Model, ModelCollection, NamedRange

from vehicle_model.Seat import Seat
from vehicle_model.SeatService import SeatService


class Cabin(Model):
    """
    A class used to represent Cabin model

    ...

    Attributes
    ----------
    1) SeatService : SeatService
        an object instantiation of SeatService class

    2) name : ModelCollection[Seat]
        a modelcollection of Seat objects
    """

    def __init__(self, parent: Model):
        super().__init__(parent)

        self.SeatService = SeatService()

        self.Seat = ModelCollection[Seat](
            [NamedRange("Row", 1, 2), NamedRange("Pos", 1, 3)], Seat(self)
        )
