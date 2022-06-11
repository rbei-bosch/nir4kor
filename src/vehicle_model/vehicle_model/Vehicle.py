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
