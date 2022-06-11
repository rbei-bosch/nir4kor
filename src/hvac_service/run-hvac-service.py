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
# ********************************************************************************/
# * Bosch Dummy Vehicle Service Client (PoC)
# ********************************************************************************/

# Disable name checks due to proto generated classes
# pylint: disable=C0103
# pylint: disable=C0114 (missing-module-docstring)
# pylint: disable=C0115 (missing-class-docstring)
# pylint: disable=C0116 (missing-function-docstring)
import asyncio
import os
import signal
import sys
import threading
import logging
import databroker

from concurrent.futures import ThreadPoolExecutor
from typing import Optional

import grpc

from proto import hvac_service_pb2_grpc
from proto.hvac_service_pb2 import OffResponse, OnResponse, SetTemperatureResponseMsg
from proto.hvac_service_pb2_grpc import HVACServiceServicer

sys.path.insert(0, "..")
exit_event = threading.Event()

log = logging.getLogger("hvac_service")


class HVACService:
    """VehicleClient provides the Graph API to access vehicle services and vehicle signals."""

    def __init__(
        self, port: Optional[int] = None
    ):
        if port is None:
            port = int(str(os.getenv("DAPR_GRPC_PORT")))

        print(port)
        self._address = f"0.0.0.0:{port}"
        self._databroker_channel = grpc.insecure_channel("127.0.0.1:55555")
        self._databroker_metadata = (
            ("dapr-app-id", "vehicledatabroker"),
        )
        self._provider = databroker.Provider(self._databroker_channel, self._databroker_metadata)

    async def listen(self, not_main_thread: bool = False):
        print("Start HVACService Listener ...", flush=True)
        _server = grpc.server(ThreadPoolExecutor(max_workers=10))
        _servicer = self._HVACServiceListener()
        hvac_service_pb2_grpc.add_HVACServiceServicer_to_server(
            _servicer, _server
        )
        _server.add_insecure_port(self._address)
        _server.start()

        def singal_handler(*args):
            print("SIGTERM received! Stopping Server!", flush=True)
            exit_event.set()
            _server.stop(0)
            sys.exit()

        if not not_main_thread:
            signal.signal(signal.SIGTERM, singal_handler)
            _server.wait_for_termination()

    async def register_datapoints(self):
        log.info("Register datapoints")
        self._provider.register(
            "Vehicle.Cabin.HVAC.Station.Row1.Left.Temperature",
            databroker.types.INT8,
            databroker.types.ON_CHANGE,
        ),
        self._provider.register(
            "Vehicle.Cabin.HVAC.Station.Row1.Left.FanSpeed",
            databroker.types.INT8,
            databroker.types.ON_CHANGE,
        )
        self._provider.register(
            "Vehicle.Cabin.HVAC.Station.IsAirConditioningActive",
            databroker.types.BOOL,
            databroker.types.ON_CHANGE,
        )
        self._provider.register(
            "Vehicle.Cabin.HVAC.DogMode",
            databroker.types.BOOL,
            databroker.types.ON_CHANGE,
        )

    async def close(self):
        """Closes runtime gRPC channel."""
        if self._channel:
            await self._channel.close()

    def __enter__(self) -> "HVACService":
        return self

    def __exit__(self, exc_type, exc_value, traceback) -> None:
        asyncio.run_coroutine_threadsafe(self.close(), asyncio.get_event_loop())

    class _HVACServiceListener(HVACServiceServicer):

        def SetTemperature(self, request, context):
            # SetTemperatureRequestMsg { temperature }
            print(request)
            setTemp = self.delegate.on_set_temperature(
                request.temperature
            )
            # SetTemperatureResponseMsg { temperature }
            return SetTemperatureResponseMsg(temperature=setTemp)

        def On(self, request, context):
            # OnMsg{ }

            result = self.delegate.on_set_on()

            # OnResponse{dummyOutInt, dummyOutFloat}
            return OnResponse

        def Off(self, request, context):
            # OffMsg{ }

            result = self.delegate.on_set_off()

            # OffResponse {dummyOutInt, dummyOutFloat}
            return OffResponse


def get_grpc_port() -> int:
    key = "DAPR_GRPC_PORT"
    default_port = 50051

    return default_port if os.getenv(key) is None else int(str(os.getenv(key)))


async def main():
    """Main function"""
    service = HVACService(get_grpc_port())
    await service.register_datapoints()
    await service.listen()


if __name__ == "__main__":
    LOOP = asyncio.get_event_loop()
    LOOP.add_signal_handler(signal.SIGTERM, LOOP.stop)
    LOOP.run_until_complete(main())
    LOOP.close()
