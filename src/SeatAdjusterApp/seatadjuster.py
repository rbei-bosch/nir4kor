# Copyright (c) 2022 Robert Bosch GmbH and Microsoft Corporation
#
# This program and the accompanying materials are made available under the
# terms of the Apache License, Version 2.0 which is available at
# https://www.apache.org/licenses/LICENSE-2.0.
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# SPDX-License-Identifier: Apache-2.0

"""A sample talent for adjusting seat positions."""

# pylint: disable=C0413, E1101

import asyncio
import json
import logging
import signal

import grpc
from sdv.util.log import get_default_date_format, get_default_log_format
from sdv.vehicle_app import VehicleApp, subscribe_topic
from vehicle_model import Vehicle, vehicle  # type: ignore
from vehicle_model.proto.seats_pb2 import BASE, SeatLocation  # type: ignore

logging.basicConfig(format=get_default_log_format(), datefmt=get_default_date_format())
logging.getLogger().setLevel("INFO")
logger = logging.getLogger(__name__)


class SeatAdjusterApp(VehicleApp):
    """
    A sample SeatAdjusterApp.

    The SeatAdjusterApp subcribes at the VehicleDataBroker for updates for the
    Vehicle.Speed signal.It also subscribes at a MQTT topic to listen for incoming
    requests to change the seat position and calls the SeatService to move the seat
    upon such a request, but only if Vehicle.Speed equals 0.
    """

    def __init__(self, vehicle_client: Vehicle):
        super().__init__()
        self.vehicle_client = vehicle_client
        self.vehicle_speed = 0

    async def on_start(self):
        """Run when the vehicle app starts"""

        ###############################################################################
        # Subscribe for -> Vehicle.Cabin.Seat.Row1.Pos1.Position and/join
        # Vehicle.Speed value change
        # REMARK: Subscribing to multipe data points is not possible now due to dapr
        # issue. Therefore, joining multiple data points is used here.
        # DAPR ISSUE: https://github.com/dapr/dapr/issues/4537
        ###############################################################################
        logger.info("Subscribe for Datapoints!")
        await self.vehicle_client.Cabin.Seat.element_at(1, 1).Position.join(
            self.vehicle_client.Speed
        ).subscribe(self.on_vehicle_seat_change)

    @subscribe_topic("seatadjuster/setPosition/request")
    async def on_set_position_request_received(self, data: str) -> None:
        """Handle set position request from GUI app from MQTT topic"""
        data = json.loads(data)
        logger.info("Set Position Request received: data=%s", data)  # noqa: E501
        resp_topic = "seatadjuster/setPosition/response"
        logger.info("Current vehicle speed is: %s", self.vehicle_speed)
        if self.vehicle_speed == 0:
            resp_data = await self.__get_processed_response(data)
            await self.__publish_data_to_topic(resp_data, resp_topic, self)
        else:
            error_msg = f"""Not allowed to move seat because vehicle speed
                is {self.vehicle_speed} and not 0"""
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

    async def on_vehicle_seat_change(self, data):
        self.vehicle_speed = data.fields["Vehicle.Speed"].float_value
        resp_data = data.fields["Vehicle.Cabin.Seat.Row1.Pos1.Position"].uint32_value
        req_data = {"position": resp_data}
        logger.info(
            "On Vehicle Data changed (Vehicle Speed : %s, Seate Position: %s)",
            self.vehicle_speed,
            req_data,
        )
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
    seat_adjuster_app = SeatAdjusterApp(vehicle)
    await seat_adjuster_app.run()


LOOP = asyncio.get_event_loop()
LOOP.add_signal_handler(signal.SIGTERM, LOOP.stop)
LOOP.run_until_complete(main())
LOOP.close()
