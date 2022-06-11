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

import swdc_comfort_seats_pb2
from set_position_request_processor import SetPositionRequestProcessor
from VehicleSdk import VehicleClient
from bfb_adapter import BfbAdapter

app = App()


@app.subscribe(pubsub_name='mqtt-pubsub', topic='seatadjuster/setPosition/request/gui-app', metadata={'rawPayload': 'true'}, )
def onSetPositionRequestGuiAppReceived(event: v1.Event) -> None:
    data = json.loads(event.Data())
    print(f'Set Position Request received: data={data}', flush=True)  # noqa: E501
    onSetPositionRequestReceived(data, "seatadjuster/setPosition/response/gui-app")


@app.subscribe(pubsub_name='mqtt-pubsub', topic='seatadjuster/setSeatPosition', metadata={'rawPayload': 'true'}, )
def onSetPositionRequestBfbAppReceived(event: v1.Event) -> None:
    bfb_data = json.loads(event.Data())
    print(f'Set Position Request received: data={bfb_data}', flush=True)  # noqa: E501
    bfbAdapter = BfbAdapter()
    data = bfbAdapter.process(bfb_data)
    onSetPositionRequestReceived(data, "seatadjuster/setPosition/response")

def onSetPositionRequestReceived(data: any, resp_topic: str) -> None:
    vehicleClient = VehicleClient()
    setPositionRequestProcessor = SetPositionRequestProcessor()
    setPositionRequestProcessor.process(data, resp_topic, vehicleClient)

if __name__ == '__main__':
    logging.basicConfig()
    print(f'Starting client...')
    app.run(50008)
