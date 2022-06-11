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
"""A sample talent for adjusting seat positions."""

# pylint: disable=C0413, E1101

import asyncio
import json
import logging
import signal

import grpc
from sdv.util.log import get_default_date_format, get_default_log_format
from sdv.vehicle_app import VehicleApp, subscribe_data_points, subscribe_topic

from vehicle_model.proto.seats_pb2 import BASE, SeatLocation
from vehicle_model.Vehicle import Vehicle, vehicle

logging.basicConfig(format=get_default_log_format(), datefmt=get_default_date_format())
logging.getLogger().setLevel("INFO")
logger = logging.getLogger(__name__)


class SeatAdjusterApp(VehicleApp):
    """
    A sample SeatAdjusterTalent.

    The SeatAdjusterTalent subcribes at the VehicleDataBroker for updates for the
    Vehicle.Speed signal.It also subscribes at a MQTT topic to listen for incoming
    requests to change the seat position and calls the SeatService to move the seat
    upon such a request, but only if Vehicle.Speed equals 0.
    """

    def __init__(self, vehicle_client: Vehicle):
        super().__init__()
        self.vehicle_client = vehicle_client

    @subscribe_topic("seatadjuster/setPosition/request")
    async def on_set_position_request_received(self, data: str) -> None:
        """Handle set position request from GUI app from MQTT topic"""
        data = json.loads(data)
        logger.info("Set Position Request received: data=%s", data)  # noqa: E501
        await self._on_set_position_request_received(
            data, "seatadjuster/setPosition/response"
        )

    async def _on_set_position_request_received(
        self, data: str, resp_topic: str
    ) -> None:
        vehicle_speed = await self.vehicle_client.Speed.get()

        if vehicle_speed == 0:
            await self._process(data, resp_topic, self)
        else:
            error_msg = f"""Not allowed to move seat because vehicle speed
                is {vehicle_speed} and not 0"""
            logger.warning(error_msg)
            resp_data = {
                "requestId": data["requestId"],  # type: ignore
                "status": 1,
                "message": error_msg,
            }
            await self.publish_mqtt_event(resp_topic, json.dumps(resp_data))

    async def _process(self, data: str, resp_topic: str, app: VehicleApp):
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
            return resp_data
        except grpc.RpcError as rpcerror:
            if rpcerror.code() == grpc.StatusCode.INVALID_ARGUMENT:
                error_msg = f"""Provided position '{data["position"]}'  \
                    should be in between (0-1000)"""
                resp_data = {
                    "requestId": data["requestId"],
                    "result": {"status": 1, "message": error_msg},
                }
                return resp_data
            error_msg = f"Received unknown RPC error: code={rpcerror.code()}\
                    message={rpcerror.details()}"  # pylint: disable=E1101
            resp_data = {
                "requestId": data["requestId"],
                "result": {"status": 1, "message": error_msg},
            }
            return resp_data

    async def __publish_data_to_topic(
        self, resp_data: dict, resp_topic: str, app: VehicleApp
    ):
        try:
            await app.publish_mqtt_event(resp_topic, json.dumps(resp_data))
        except Exception as ex:
            error_msg = f"Exception details: {ex}"
            logger.error(error_msg)

    @subscribe_data_points("Vehicle.Cabin.Seat.Row1.Pos1.Position")
    async def on_vehicle_seat_change(self, data):
        resp_data = data.fields["Vehicle.Cabin.Seat.Row1.Pos1.Position"].uint32_value
        req_data = {"position": resp_data}
        logger.info("Current Position of the Vehicle Seat is: %s", req_data)
        try:
            await self.publish_mqtt_event(
                "seatadjuster/currentPosition", json.dumps(req_data)
            )
        except Exception as ex:
            logger.info("Unable to get Current Seat Position, Exception: %s", ex)
            resp_data = {"requestId": data["requestId"], "status": 1, "message": ex}
            await self.publish_mqtt_event(
                "seatadjuster/currentPosition", json.dumps(resp_data)
            )


async def main():
    """Main function"""
    logger.info("Starting seat adjuster app...")
    seat_adjuster_talent = SeatAdjusterApp(vehicle)
    await seat_adjuster_talent.run()


LOOP = asyncio.get_event_loop()
LOOP.add_signal_handler(signal.SIGTERM, LOOP.stop)
LOOP.run_until_complete(main())
LOOP.close()
