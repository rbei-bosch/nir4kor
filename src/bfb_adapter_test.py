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

from bfb_adapter import BfbAdapter

def test_process():
    bfbAdapter = BfbAdapter()
    requestData = getSampleRequestData()
    response = bfbAdapter.process(requestData)
    assert response["requestId"] == requestData["cId"]
    assert response["position"] == requestData["p"]["value"]


def getSampleRequestData():
    return {"cId":123, "p": {"value": "sample"}}