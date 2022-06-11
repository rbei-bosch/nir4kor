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

from sdv.client import VehicleClient
from sdv.proto.swdc_comfort_seats_pb2 import BASE, SeatLocation
from sdv.talent import Talent


class SetPositionRequestProcessor:
    """A class to process position requests."""

    async def process(
        self, data: str, resp_topic: str, vehicle_client: VehicleClient, talent: Talent
    ):
        """Process the position request."""
        resp_data = await self.__get_processed_response(data, vehicle_client)
        await self.__publish_data_to_topic(resp_data, resp_topic, talent)

    async def __get_processed_response(self, data, vehicle_client):
        try:
            location = SeatLocation(row=1, index=1)
            await vehicle_client.Seats.MoveComponent(location, BASE, data["position"])
            resp_data = {"requestId": data["requestId"], "result": {"status": 0}}
        except Exception as ex:
            resp_data = {
                "requestId": data["requestId"],
                "result": {"status": 1, "message": self.__get_error_message_from(ex)},
            }
        return resp_data

    async def __publish_data_to_topic(
        self, resp_data: dict, resp_topic: str, talent: Talent
    ):
        status = 0
        try:
            await talent.publish_mqtt_event(resp_topic, json.dumps(resp_data))
        except Exception:
            status = -1
        return status

    def __get_error_message_from(self, ex: Exception):
        return f"Exception details: {ex}"
