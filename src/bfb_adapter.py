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

import json
import logging
import os
from typing import Any

# from __future__ import print_function
from cloudevents.sdk.event import v1
from dapr.ext.grpc import App
from flask import jsonify, request
from grpc import local_channel_credentials

from VehicleSdk import VehicleClient

class BfbAdapter:
    def process(self, data: any):
        resp_data = {
            'requestId': data["cId"],
            'position': data["p"]["value"]
        }
        return resp_data;