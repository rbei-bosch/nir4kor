# /********************************************************************************
# * Copyright (c) 2021 Contributors to the Eclipse Foundation
# *
# * See the NOTICE file(s) distributed with this work for additional
# * information regarding copyright ownership.
# *
# * This program and the accompanying materials are made available under the
# * terms of the Eclipse Public License 2.0 which is available at
# * http://www.eclipse.org/legal/epl-2.0
# *
# * SPDX-License-Identifier: EPL-2.0
# ********************************************************************************/

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
