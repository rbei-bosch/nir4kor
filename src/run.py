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

import asyncio
import json
import logging
import signal

from sdv.proto.databroker_pb2 import Notification
from sdv.talent import Talent, subscribe_data_points, subscribe_topic

from set_position_request_processor import SetPositionRequestProcessor


class SeatAdjusterTalent(Talent):
    """
    A sample SeatAdjusterTalent.

    The SeatAdjusterTalent subcribes at the VehicleDataBroker for updates for the
    Vehicle.Speed signal.It also subscribes at a MQTT topic to listen for incoming
    requests to change the seat position and calls the SeatService to move the seat
    upon such a request, but only if Vehicle.Speed equals 0.
    """

    @subscribe_topic("seatadjuster/setPosition/request/gui-app")
    async def on_set_position_request_received(self, data: str) -> None:
        """Handle set position request from GUI app from MQTT topic"""
        data = json.loads(data)
        print(f"Set Position Request received: data={data}", flush=True)  # noqa: E501
        await self._on_set_position_request_received(
            data, "seatadjuster/setPosition/response/gui-app"
        )

    async def _on_set_position_request_received(
        self, data: str, resp_topic: str
    ) -> None:
        vehicle_speed = await self.vehicle_client.get_vehicle_speed()
        if vehicle_speed == 0:
            processor = SetPositionRequestProcessor()
            await processor.process(data, resp_topic, self.vehicle_client, self)
        else:
            print(
                "Not allowed to move seat because vehicle speed is {vehicleSpeed} and not 0"
            )

    @subscribe_data_points(["Vehicle.Speed"])
    def on_vehicle_speed_change(self, notification: Notification):  # type: ignore
        """Handle vehicle speed change"""
        print(notification, flush=True)


async def main():
    """Main function"""
    logging.basicConfig()
    print("Starting seat adjuster app...", flush=True)
    seat_adjuster_talent = SeatAdjusterTalent()
    await seat_adjuster_talent.run()


LOOP = asyncio.get_event_loop()
LOOP.add_signal_handler(signal.SIGTERM, LOOP.stop)
LOOP.run_until_complete(main())
LOOP.close()
