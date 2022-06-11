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

import sys
import os
import grpc

import swdc_comfort_seats_pb2
import swdc_comfort_seats_pb2_grpc
from dapr.proto import api_service_v1, api_v1

from typing import Optional

class VehicleClient:
    def __init__(self, port: Optional[int] = None):
        if not port:
            port = os.getenv('DAPR_GRPC_PORT')
        self._address = f'localhost:{port}'
        self._channel = grpc.insecure_channel(self._address)   # type: ignore
        self._metadata = (('dapr-app-id', 'vehicleapi'),)
        self._daprStub =  api_service_v1.DaprStub(self._channel)
        self.Seats = self._Seats(self._channel, self._metadata)

    def close(self):
        """Closes runtime gRPC channel."""
        if self._channel:
            self._channel.close()

    def __del__(self):
        self.close()

    def __enter__(self) -> 'VehicleClient':
        return self

    def __exit__(self, exc_type, exc_value, traceback) -> None:
        self.close()

    def PublishEvent(self, topic: str, data: any):
        req = api_v1.PublishEventRequest(
            pubsub_name='mqtt-pubsub',
            topic=topic,
            data=bytes(data, 'utf-8'),
            metadata={'rawPayload': 'true'},)
        self._daprStub.PublishEvent(req)

    class _Seats:
        def __init__(self, channel, metadata):
            self._stub = swdc_comfort_seats_pb2_grpc.SeatsStub(channel)   # type: ignore
            self._metadata = metadata

        def Move(self, seat: swdc_comfort_seats_pb2.Seat):
            response = self._stub.Move.with_call(swdc_comfort_seats_pb2.MoveRequest(seat = seat), 
                metadata=self._metadata)
            return response

        def MoveComponent(self, seatLocation: swdc_comfort_seats_pb2.SeatLocation, component: swdc_comfort_seats_pb2.SeatComponent, position: int):
            response = self._stub.MoveComponent.with_call(swdc_comfort_seats_pb2.MoveComponentRequest(seat = seatLocation, component = component, position = position), 
                metadata=self._metadata)
            return response

        def CurrentPosition(self, row: int, index: int):
            response = self._stub.CurrentPosition.with_call(swdc_comfort_seats_pb2.CurrentPositionRequest(row = row, index = index), 
                metadata=self._metadata)
            return response

