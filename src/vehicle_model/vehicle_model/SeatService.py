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

# pylint: disable=C0103

from sdv.model import Service

from vehicle_model.proto.seats_pb2 import (
    CurrentPositionRequest,
    MoveComponentRequest,
    MoveRequest,
    Seat,
    SeatComponent,
    SeatLocation,
)
from vehicle_model.proto.seats_pb2_grpc import SeatsStub


class SeatService(Service):
    """
    Seats service for getting and controlling the positions of the seats
    and their components in the vehicle.
    This definition corresponds to the COVESA Vehicle Service Catalog (VSC)
    comfort seats service definition
    (https://github.com/COVESA/vehicle_service_catalog)

    ...

    Methods
    ----------
    Move(seat=Seat)
        Set the desired seat position

    MoveComponent(seatLocation=SeatLocation, component=SeatComponent, position=int)
        Set a seat component position

    CurrentPosition(row=int, index=int)
        Get the current position of the addressed seat

    """

    def __init__(self):
        super().__init__()
        self._stub = SeatsStub(self.channel)

    async def Move(self, seat: Seat):
        """
        Summary
        -------
            Set the desired seat position

        Parameters
        ----------
        seat : Seat
            The seat which needs to be moved

        Returns
        -------
            * OK - Seat movement started
            * OUT_OF_RANGE - The addressed seat is not present in this vehicle
            * INVALID_ARGUMENT - At least one of the requested component positions is invalid
            * INTERNAL - A seat service internal error happened - see error message for details
        """
        response = await self._stub.Move(MoveRequest(seat=seat), metadata=self.metadata)
        return response

    async def MoveComponent(
        self,
        seatLocation: SeatLocation,
        component: SeatComponent,
        position: int,
    ):
        """
        Parameters
        ----------
        seatLocation : SeatLocation
            The location of the seat in which the component is present
        component : SeatComponent
            The component of the seat which needs to be moved
        position : int
            The units by which the component has to move

        Returns
        -------
            * OK - Seat movement started
            * OUT_OF_RANGE - The addressed seat is not present in this vehicle
            * NOT_FOUND - The addressed seat component is not supported by this seat/vehicle
            * INVALID_ARGUMENT - At least one of the requested component positions is invalid
            * INTERNAL - A seat service internal error happened - see error message for details

        """
        response = await self._stub.MoveComponent(
            MoveComponentRequest(
                seat=seatLocation,
                component=component,  # type: ignore
                position=position,
            ),
            metadata=self.metadata,
        )
        return response

    async def CurrentPosition(self, row: int, index: int):
        """
        Parameters
        ----------
        row : int
            The row of the seat
        index : int
            The index of the seat

        Returns
        -------
            * OK - Seat positions returned
            * OUT_OF_RANGE - The addressed seat is not present in this vehicle
        """
        response = await self._stub.CurrentPosition(
            CurrentPositionRequest(row=row, index=index),
            metadata=self.metadata,
        )
        return response
