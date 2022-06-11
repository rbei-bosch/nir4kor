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
"""A sample for adjusting seat positions."""

# For more information on how to create a Vehicle App see also this tutorial:
# https://github.com/SoftwareDefinedVehicle/velocitas-docs/blob/main/docs/python-sdk/tutorial_how_to_create_a_vehicle_app.md

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

# Use default logging format provided by sdv sdk
logging.basicConfig(format=get_default_log_format(), datefmt=get_default_date_format())


# Define minimum log level
logging.getLogger().setLevel("INFO")

logger = logging.getLogger(__name__)

# Inherit the app from VehicleApp base class. Learn more about the VehicleApp abstraction at
# https://github.com/SoftwareDefinedVehicle/velocitas-docs/blob/main/docs/python-sdk/python_vehicle_app_sdk_overview.md#Vehicle-App-abstraction


class SeatAdjusterApp(VehicleApp):
    """
    A sample SeatAdjusterApp.

    The SeatAdjusterApp subcribes at the VehicleDataBroker for updates for the
    Vehicle.Speed signal.It also subscribes at a MQTT topic to listen for incoming
    requests to change the seat position and calls the SeatService to move the seat
    upon such a request, but only if Vehicle.Speed equals 0.
    """

    # Provide a vehicle model (client) to the app to access the vehicle abstraction layer
    # A sample vehicle model is provided in the src/vehicle_model directory
    # If you want to create your own vehicle model, check out this tutorial:
    # https://github.com/SoftwareDefinedVehicle/velocitas-docs/blob/main/docs/python-sdk/tutorial_how_to_create_a_vehicle_model.md
    def __init__(self, vehicle_client: Vehicle):
        super().__init__()
        self.vehicle_client = vehicle_client

    # Subscribe to a MQTT topic with the subscribe_topic annotation. The annotated method
    # will be called each time, a new message is published to the subscribed topic.
    @subscribe_topic("seatadjuster/setPosition/request")
    async def on_set_position_request_received(self, data: str) -> None:
        """Handle set position request from GUI app from MQTT topic"""
        data = json.loads(data)
        logger.info("Set Position Request received: data=%s", data)  # noqa: E501
        resp_topic = "seatadjuster/setPosition/response"

        # Use the vehicle client to get vehicle signals from the vehicle abstraction layer
        # This retrieves the latest vehicle speed signal:
        vehicle_speed = await self.vehicle_client.Speed.get()
        if vehicle_speed == 0:
            resp_data = await self.__get_processed_response(data)
            await self.__publish_data_to_topic(resp_data, resp_topic, self)
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

    async def __get_processed_response(self, data):
        try:
            location = SeatLocation(row=1, index=1)
            # Use the vehicle client to invoke methods on the vehicle abstraction layer
            # This triggers a movemenet of the seat:
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
            # The VehicleApp provides a convenient way to publish data to a MQTT topic
            # throught the publish_mqtt_event method
            await app.publish_mqtt_event(resp_topic, json.dumps(resp_data))
        except Exception as ex:
            error_msg = f"Exception details: {ex}"
            logger.error(error_msg)

    # Use the subscribe_data_points annotation to subscribe to data points from the vehicle
    # data broker. The annotated method will be called each time a new value is published
    # to the broker. Optionally, specify a condition as a second parameter to constrain the
    # subscription.
    # The subscription will be active as long as the app is running. If you need to
    # subscribe and unsubscribe dynamically, create subscriptions with the fluent API.
    # Learn more about the fluent API at
    # https://github.com/SoftwareDefinedVehicle/velocitas-docs/blob/main/docs/python-sdk/python_vehicle_app_sdk_overview.md#fluent-query--rule-construction
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

    # Initialization logic like loading data from the vehicle abstraction layer
    # should be placed in the on_start method.
    # IMPORTANT: Don´t use the vehicle client before (e.g. in main()), because
    # it isn´t initialized yet.
    async def on_start(self):
        """Executed after the vehicle app is initialized"""


# The main method should instantiate the app and call the run() method
async def main():
    """Main function"""
    logger.info("Starting seat adjuster app...")
    seat_adjuster_app = SeatAdjusterApp(vehicle)
    await seat_adjuster_app.run()


# VehicleApps requires an asyncio event loop to run
LOOP = asyncio.get_event_loop()
LOOP.add_signal_handler(signal.SIGTERM, LOOP.stop)
LOOP.run_until_complete(main())
LOOP.close()
