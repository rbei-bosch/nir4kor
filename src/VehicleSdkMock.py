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

import swdc_comfort_seats_pb2
import swdc_comfort_seats_pb2_grpc

class VehicleSdkMock:
    def Move(self, seat: swdc_comfort_seats_pb2.Seat, port: int):
        return seat.position.base

    def MoveComponent(self, seat: swdc_comfort_seats_pb2.Seat, component: swdc_comfort_seats_pb2.SeatComponent, position: int, port: int):
        return position

    def CurrentPosition(row: int, index: int):
        return 1