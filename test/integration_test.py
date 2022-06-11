import json
import time

import paho.mqtt.client as mqtt


class MessageCallback:
    """This class is a wrapper for the on_message callback of the MQTT broker."""

    def __init__(self):
        self.message = None

    def __call__(self, client, userdata, message):
        self.message = message


def test_set_position():
    request_id = "abc"
    request_topic = "seatadjuster/setPosition/request/gui-app"
    response_topic = "seatadjuster/setPosition/response/gui-app"
    mqtt_hostname = "localhost"
    mqtt_port = 31883
    timeout = 20000

    payload = {"position": 300, "requestId": request_id}

    client = mqtt.Client()
    client.connect(host=mqtt_hostname, port=mqtt_port)

    msg_callback = MessageCallback()
    client.on_message = msg_callback

    client.subscribe(topic=response_topic)

    client.loop_start()

    counter = 0
    interval = 100

    while msg_callback.message is None and counter < timeout:
        client.publish(topic=request_topic, payload=json.dumps(payload))
        counter += interval
        time.sleep(interval / 1000)

    client.loop_stop()

    assert msg_callback.message is not None

    body = json.loads(str(msg_callback.message.payload.decode("utf-8")))

    assert body["requestId"] == request_id
    assert body["result"]["status"] == 0
