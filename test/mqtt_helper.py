import json
import os
import time
from typing import Optional

import paho.mqtt.client as mqtt


class MessageCallback:
    """This class is a wrapper for the on_message callback of the MQTT broker."""

    def __init__(self):
        self.message = None

    def __call__(self, client, userdata, message):
        self.message = message


class MqttClient:
    """This class is a wrapper for the on_message callback of the MQTT broker."""

    def __init__(self, port: Optional[int] = None):
        if port is None:
            value = str(os.getenv("MQTT_PORT"))

            if value is not None:
                port = int(value)

        if port is None:
            port = 1883  # default port of MQTT Broker when running locally

        self._port = port
        self._hostname = "localhost"

        self._client = mqtt.Client()
        self._callback = MessageCallback()
        self._client.on_message = self._callback

    def connect(self):
        self._client.connect(self._hostname, self._port)

    def publish_and_wait_for_response(
        self, request_topic: str, response_topic: str, payload, timeout: int = 20000
    ) -> str:
        if not self._client.is_connected():
            self.connect()

        counter = 0
        interval = 100

        self._client.subscribe(response_topic)

        self._client.loop_start()

        self._client.publish(request_topic, json.dumps(payload))

        while self._callback.message is None and counter < timeout:
            counter += interval
            time.sleep(interval / 1000)

        self._client.loop_stop()

        return self._callback.message
