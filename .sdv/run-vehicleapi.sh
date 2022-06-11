#!/bin/sh

PKG_PATH=$(python -c 'import os,inspect,sdv; print(os.path.dirname(inspect.getfile(sdv)))')


dapr run --app-id vehicleapi --app-protocol grpc --app-port 50051 --components-path ./.dapr/components --config ./.dapr/config.yaml \
python3 $PKG_PATH/vehicle_api_mock/vehicleapi.py
