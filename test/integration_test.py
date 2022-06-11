import json
from asyncio import sleep

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
    speed_value = 50
    response = await inttesthelper.set_float_datapoint(
        name="Vehicle.Speed", value=speed_value
    )

    assert len(response.errors) == 0

    response = mqtt_client.publish_and_wait_for_response(
        request_topic=pytest.request_topic,
        response_topic=pytest.response_topic,
        payload=payload,
    )

    assert response != ""

    body = json.loads(response)
    error_msg = f"""Not allowed to move seat because vehicle speed
                is {float(speed_value)} and not 0"""
    assert body["requestId"] == request_id
    assert body["status"] == 1
    assert body["message"] == error_msg


# add message to get it assert


@pytest.mark.asyncio
async def test_set_position_allowed():
    mqtt_client = MqttClient(pytest.mqtt_port)
    inttesthelper = IntTestHelper(pytest.inttesthelper_port)
    request_id = "abc"

    payload = {"position": 0, "requestId": request_id}

    response = await inttesthelper.set_float_datapoint(name="Vehicle.Speed", value=0)

    assert len(response.errors) == 0

    response = mqtt_client.publish_and_wait_for_response(
        request_topic=pytest.request_topic,
        response_topic=pytest.response_topic,
        payload=payload,
    )

    body = json.loads(response)
    assert body["result"]["status"] == 0

    await sleep(1)

    position = 200
    payload = {"position": position, "requestId": request_id}

    response = mqtt_client.publish_and_wait_for_property(
        request_topic=pytest.request_topic,
        response_topic="seatadjuster/currentPosition",
        payload=payload,
        path=["position"],
        value=position,
    )

    assert response != ""

    body = json.loads(response)
    assert body["position"] == position


@pytest.mark.asyncio
async def test_set_position_lt_0():
    mqtt_client = MqttClient(pytest.mqtt_port)
    inttesthelper = IntTestHelper(pytest.inttesthelper_port)
    request_id = "abc"
    seat_position = -1
    payload = {"position": seat_position, "requestId": request_id}

    response = await inttesthelper.set_float_datapoint(name="Vehicle.Speed", value=0)

    assert len(response.errors) == 0

    response = mqtt_client.publish_and_wait_for_response(
        request_topic=pytest.request_topic,
        response_topic=pytest.response_topic,
        payload=payload,
    )

    assert response != ""

    body = json.loads(response)
    error_msg = f"""Provided position '{seat_position}'  \
                    should be in between (0-1000)"""
    assert body["requestId"] == request_id
    assert body["result"]["status"] == 1
    assert body["result"]["message"] == error_msg


@pytest.mark.asyncio
async def test_set_position__gt_1000():
    mqtt_client = MqttClient(pytest.mqtt_port)
    inttesthelper = IntTestHelper(pytest.inttesthelper_port)
    request_id = "abc"
    seat_position = 1001
    payload = {"position": seat_position, "requestId": request_id}

    response = await inttesthelper.set_float_datapoint(name="Vehicle.Speed", value=0)

    assert len(response.errors) == 0

    response = mqtt_client.publish_and_wait_for_response(
        request_topic=pytest.request_topic,
        response_topic=pytest.response_topic,
        payload=payload,
    )

    assert response != ""

    body = json.loads(response)
    error_msg = f"""Provided position '{seat_position}'  \
                    should be in between (0-1000)"""
    assert body["requestId"] == request_id
    assert body["result"]["status"] == 1
    assert body["result"]["message"] == error_msg
