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


from concurrent import futures
import logging

import json


import grpc
import swdc_comfort_seats_pb2
import swdc_comfort_seats_pb2_grpc

from dapr.clients import DaprClient


class VehicleApi(swdc_comfort_seats_pb2_grpc.SeatsServicer):

    def Move(self, request, context):
        print("New position is ", request.seat.position, flush=True)

        req_data = {
            'id': request.seat.position.base,
            'SeatPosition': request.seat.position.base
        }

        with DaprClient() as d:
            # Create a typed message with content type and body
            resp = d.publish_event(
                pubsub_name='mqtt-pubsub',
                topic_name='SEATPOSITION',
                data=json.dumps(req_data),
                data_content_type='application/json',
            )

        return swdc_comfort_seats_pb2.MoveReply()

    def MoveComponent(self, request, context):
        print("New component position is ", request.position, flush=True)

        req_data = {
            'location-index': request.seat.index,
            'location-row': request.seat.row,
            'component': request.component,
            'position': request.position
        }

        with DaprClient() as d:
            # Create a typed message with content type and body
            resp = d.publish_event(
                pubsub_name='mqtt-pubsub',
                topic_name='SEATCOMPONENTPOSITION',
                data=json.dumps(req_data),
                data_content_type='application/json',
            )

        return swdc_comfort_seats_pb2.MoveComponentReply()

    def CurrentPosition(self, request, context):
        print("Received CurrentPosition request for seat in row ", request.row, ", index ", request.index, flush=True)

        return swdc_comfort_seats_pb2.CurrentPositionReply()

def serve():
    port = '127.0.0.1:50051'
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    swdc_comfort_seats_pb2_grpc.add_SeatsServicer_to_server(VehicleApi(), server)
    server.add_insecure_port(port)
    server.start()
    print("Listening on port ", port, flush=True)
    server.wait_for_termination()


if __name__ == '__main__':
    logging.basicConfig()
    serve()
