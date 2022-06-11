import json

import pytest
from mqtt_helper import MqttClient
from sdv.test.inttesthelper import IntTestHelper


@pytest.mark.asyncio
@pytest.fixture(scope="session", autouse=True)
def pytest_configure():
    # # Use these for local execution
    # pytest.mqtt_port = 1883
    # pytest.inttesthelper_port = 55555

    # Use these for cluster execution
    pytest.mqtt_port = 31883
    pytest.inttesthelper_port = 30555

    pytest.request_topic = "seatadjuster/setPosition/request"
    pytest.response_topic = "seatadjuster/setPosition/response"


@pytest.mark.asyncio
async def test_set_position_not_allowed():
    mqtt_client = MqttClient(pytest.mqtt_port)
    inttesthelper = IntTestHelper(pytest.inttesthelper_port)
    request_id = "abc"

    payload = {"position": 300, "requestId": request_id}

    response = await inttesthelper.set_float_datapoint(name="Vehicle.Speed", value=50)

    assert len(response.errors) == 0

    response = mqtt_client.publish_and_wait_for_response(
        request_topic=pytest.request_topic,
        response_topic=pytest.response_topic,
        payload=payload,
    )

    assert response is not None

    body = json.loads(str(response.payload.decode("utf-8")))

    assert body["requestId"] == request_id
    assert body["status"] == 1


@pytest.mark.asyncio
async def test_set_position_allowed():
    mqtt_client = MqttClient(pytest.mqtt_port)
    inttesthelper = IntTestHelper(pytest.inttesthelper_port)
    request_id = "abc"

    payload = {"position": 300, "requestId": request_id}

    response = await inttesthelper.set_float_datapoint(name="Vehicle.Speed", value=0)

    assert len(response.errors) == 0

    response = mqtt_client.publish_and_wait_for_response(
        request_topic=pytest.request_topic,
        response_topic=pytest.response_topic,
        payload=payload,
    )

    assert response is not None

    body = json.loads(str(response.payload.decode("utf-8")))

    assert body["requestId"] == request_id
    assert body["result"]["status"] == 0


@pytest.mark.asyncio
async def test_set_position_lt_0():
    mqtt_client = MqttClient(pytest.mqtt_port)
    inttesthelper = IntTestHelper(pytest.inttesthelper_port)
    request_id = "abc"

    payload = {"position": -1, "requestId": request_id}

    response = await inttesthelper.set_float_datapoint(name="Vehicle.Speed", value=0)

    assert len(response.errors) == 0

    response = mqtt_client.publish_and_wait_for_response(
        request_topic=pytest.request_topic,
        response_topic=pytest.response_topic,
        payload=payload,
    )

    assert response is not None

    body = json.loads(str(response.payload.decode("utf-8")))

    assert body["requestId"] == request_id
    assert body["result"]["status"] == 1


@pytest.mark.asyncio
async def test_set_position__gt_1000():
    mqtt_client = MqttClient(pytest.mqtt_port)
    inttesthelper = IntTestHelper(pytest.inttesthelper_port)
    request_id = "abc"

    payload = {"position": 1001, "requestId": request_id}

    response = await inttesthelper.set_float_datapoint(name="Vehicle.Speed", value=0)

    assert len(response.errors) == 0

    response = mqtt_client.publish_and_wait_for_response(
        request_topic=pytest.request_topic,
        response_topic=pytest.response_topic,
        payload=payload,
    )

    assert response is not None

    body = json.loads(str(response.payload.decode("utf-8")))

    assert body["requestId"] == request_id
    assert body["result"]["status"] == 1
