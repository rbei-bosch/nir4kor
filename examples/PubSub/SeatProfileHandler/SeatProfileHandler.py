# ------------------------------------------------------------
# Copyright (c) Microsoft Corporation and Dapr Contributors.
# Licensed under the MIT License.
# ------------------------------------------------------------

import json
import time

from dapr.clients import DaprClient

with DaprClient() as d:
    id = 0
    while True:
        id += 1
        req_data = {
            'id': id,
            'SeatPosition': id
        }

        # Print the request
        print('Sending request ' + str(req_data), flush=True)

        # Create a typed message with content type and body
        resp = d.publish_event(
            pubsub_name='mqtt-pubsub',
            topic_name='SEATPOSITION',
            data=json.dumps(req_data),
            data_content_type='application/json',
        )

        time.sleep(2)
