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

"""This module contains the SetPositionRequestProcessor class."""

import json
import logging

from sdv.vehicle_app import VehicleApp

from vdm.proto.seats_pb2 import BASE, SeatLocation
from vdm.Vehicle import Vehicle

logger = logging.getLogger(__name__)


class SetPositionRequestProcessor:
    """A class to process position requests."""

    def __init__(self, vehicle_client: Vehicle):
        self.vehicle_client = vehicle_client

    async def process(self, data: str, resp_topic: str, app: VehicleApp):
        """Process the position request."""
        resp_data = await self.__get_processed_response(data)
        await self.__publish_data_to_topic(resp_data, resp_topic, app)

    async def __get_processed_response(self, data):
        try:
            location = SeatLocation(row=1, index=1)
            await self.vehicle_client.Cabin.SeatService.MoveComponent(
                location, BASE, data["position"]  # type: ignore
            )
            resp_data = {"requestId": data["requestId"], "result": {"status": 0}}
        except Exception as ex:
            resp_data = {
                "requestId": data["requestId"],
                "result": {"status": 1, "message": self.__get_error_message_from(ex)},
            }
        return resp_data

    async def __publish_data_to_topic(
        self, resp_data: dict, resp_topic: str, app: VehicleApp
    ):
        try:
            await app.publish_mqtt_event(resp_topic, json.dumps(resp_data))
        except Exception as ex:
            logger.error(self.__get_error_message_from(ex))

    def __get_error_message_from(self, ex: Exception):
        return f"Exception details: {ex}"
