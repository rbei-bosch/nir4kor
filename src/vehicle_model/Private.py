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

from sdv.model import Model

from vehicle_model.J1939 import J1939


class Private(Model):
    """Private model"""

    def __init__(self, parent: Model):
        super().__init__(parent)

        self.J1939 = J1939(self)
