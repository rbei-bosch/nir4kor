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

from sdv.model import DataPointBool, Model


class Seat(Model):
    """
    A class used to represent Seat model

    ...

    Attributes
    ----------
    Position : DataPointBool
        an object instantiation of DataPointBool class
    """

    def __init__(self, parent):
        super().__init__(parent)
        self.Position = DataPointBool("Position", self)
