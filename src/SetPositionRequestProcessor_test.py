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


from set_position_request_processor import SetPositionRequestProcessor
from VehicleSdk import VehicleClient


def test_for_exception_SetPositionRequestProcessor():
    response = getSetPositionRequestProcessorInstance().getProcessedResponse(getSampleRequestData(), getVehicleClientInstance())
    message = response["result"]["message"]
    hasException = message.__contains__("Exception details:")
    assert hasException

# def test_with_bfb_app_publishDataToTopic():
#     responseStatus = getSetPositionRequestProcessorInstance().publishDataToTopic(getSampleRequestData(), "bfb-app", getVehicleClientInstance())
#     assert responseStatus == 0

# def test_with_gui_app_publishDataToTopic():
#     responseStatus = getSetPositionRequestProcessorInstance().publishDataToTopic(getSampleRequestData(), "gui-app", getVehicleClientInstance())
#     assert responseStatus == 0

def test_for_exception_with_bfb_app_publishDataToTopic():
    responseStatus = getSetPositionRequestProcessorInstance().publishDataToTopic(getSampleRequestData(), "bfb-app", getVehicleClientInstance())
    assert responseStatus == -1

def test_for_exception_with_gui_app_publishDataToTopic():
    responseStatus = getSetPositionRequestProcessorInstance().publishDataToTopic(getSampleRequestData(), "gui-app", getVehicleClientInstance())
    assert responseStatus == -1

def getSampleRequestData():
    return {"position": 330, "requestId": "123456789"}

def getSetPositionRequestProcessorInstance():
    return SetPositionRequestProcessor()

def getVehicleClientInstance():
    return VehicleClient()