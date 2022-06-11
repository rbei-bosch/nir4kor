from cloudevents.sdk.event import v1
from dapr.ext.grpc import App

import json

app = App()


@app.subscribe(pubsub_name='mqtt-pubsub', topic='SEATPOSITION')
def mytopic(event: v1.Event) -> None:
    data = json.loads(event.Data())
    print(f'Subscriber received: id={data["id"]}, SeatPosition="{data["SeatPosition"]}", content_type="{event.content_type}"', flush=True)  # noqa: E501


app.run(50052)
