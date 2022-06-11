# VehicleApp using Python

This Python vehicleApp repository includes a sample vehicleApp based on the Software defined vehicle platform. GitHub workflows are used to build the container image for the vehicleApp, run unit and integration tests, collect the test results and create a release documentation and
publish the vehicleApp. A detailed description of the workflow you can find [here](https://github.com/SoftwareDefinedVehicle/swdc-iotea-talent-template-repositories/blob/main/docs/vehicle_app_releases.md).
 
![refernce Architecture](https://raw.githubusercontent.com/SoftwareDefinedVehicle/swdc-iotea-talent-template-repositories/main/docs/assets/publish_container.png?token=AA67KRN36QNSSQTHLGN5FLLBSTIL4)  


Note: this is a template repository. Please create your own repository from this template repository by clicking the green button `Use this template`.

## VehicleApp Development with Visual Studio Code

### System Requirements

* Docker Engine/[Docker Desktop](https://www.docker.com/products/docker-desktop)
* [Visual Studio Code](https://code.visualstudio.com)
  * The extension [Remote-Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) is installed, e.g. with `code --install-extension ms-vscode-remote.remote-containers`

<details>
      <summary>:see_no_evil: If you working behind a corporate proxy: Configure proxy for .devcontainer [click here] </summary>

> Disclaimer: Non proxy configuration is used by default


1. In Windows: Edit environment variables for your account
2. Create environment variable with name: `DEVCONTAINER_PROXY` with the value `.Proxy`
   * Don't forget (dot) in value of the environment variable
3. Restart Visual Studio Code to pick up new environment variable
4. Optional (in case of any problems): Make sure you clean all images and volumes in Docker Desktop, otherwise cache might be used

### Troubleshooting
If for some reason the devcontainer is not working, then check the `.docker\config.json` file in User profile directory.

The `.docker\config.json` has to have following proxy settings:

```json
{
   "credsStore":"desktop",
   "proxies":{
         "default":{
            "httpProxy":"http://host.docker.internal:3128",
            "httpsProxy":"http://host.docker.internal:3128",
            "noProxy":"host.docker.internal,localhost,127.0.0.1,.bosch.com"
         }
      },
      "stackOrchestrator":"swarm"
   }
}
```
</details>

### Getting started

1. Clone and set up the environment using a [Visual Studio Code development container](https://code.visualstudio.com/docs/remote/create-dev-container#:~:text=%20Create%20a%20development%20container%20%201%20Path,additional%20software%20in%20your%20dev%20container.%20More%20).
   * Start Visual Studio Code
   * Press <kbd>F1</kbd> and run the command `Remote-Containers: Clone Repository within Container Volume...`
     * Select `Clone a repository from GitHub in a Container Volume` and choose the repository / branch to clone
     * Enter the GitHub organization and repository name (e.g. `MyOrg/MyFirstVehicleApp`) and select the repository from the list
     * Select the branch to clone from the list
     > If the development container fails to build successfully (e.g. due to network issues) then wait for the current build to finish and then press <kbd>F1</kbd> and run the command `Remote-Containers: Rebuild Container Without Cache`

1. Start the VehicleApi Mock

   ```bash
   dapr run --app-id vehicleapi --app-protocol grpc --app-port 50051 --components-path ./.dapr/components --config ./.dapr/config.yaml  python3 ./vehicleapi/vehicleapi.py
   ```

1. Start and check sample vehicleApp

   ```bash
   dapr run --app-id app-skeleton --app-protocol grpc --app-port 50008 --config ./.dapr/config.yaml --components-path ./.dapr/components  python3 ./src/client.py 
   ```

1. Debug the sample vehicleApp

> If opening the devcontainer for the first time, a manual reload of the dapr extension is required. 

   * Press <kbd>F5</kbd> to start the vehicleVapp and see the log output on the `DEBUG CONSOLE`    

   * To debug the vehicleAPI Mock and the vehicle app together, choose the "SeatAdjuster" compound configuration and run it. 

1. Run unit test and adjust tests
   * Run the unit tests from the Visual Studio Code test runner by clicking on the Testrunner in the toolbar and press on the play button
     

1. dapr Dashboard
   * The dapr dashboard provides provides an overview over running dapr components and configuration.
   * To launch the dashboard in a web browser, open a terminal and type `dapr dashboard`   
   
1. Zipkin Tracing
   * Open forwarded ports in VS Code and add port 9411 if not available
   * Click on `Open in Browser` on forwarded port to open the Zipkin Tracing in the web browser.
     
1. Cleanup

   To stop your services from running, simply stop the "dapr run" process. Alternatively, you can spin down each of your services with the Dapr CLI "stop" command. For example, to spin down both services, run these commands in a new terminal: 

   <!-- STEP
   expected_stdout_lines: 
     - 'app stopped successfully: nodeapp'
     - 'app stopped successfully: pythonapp'
   expected_stderr_lines:
   output_match_mode: substring
   name: Shutdown dapr
   -->

   ```bash
   dapr stop --app-id app-skeleton 
   ```

   ```bash
   dapr stop --app-id vehicleapi
   ```

   <!-- END_STEP -->

   To see that services have stopped running, run `dapr list`, noting that your services no longer appears!

1. Recompile Protobuf 

   To recompile the proto files, the following command can be used. 
   ```bash
   python3 -m grpc_tools.protoc --proto_path=./proto/ --python_out=./vehicleapi/    --grpc_python_out=./vehicleapi/ ./proto/vehicleapi.proto
   ```

1. Request Seat-Adjustment inside the vehicle

Send MQTT message to topic `seatadjuster/setPosition/request/gui-app`. 

Example:
```json
{"position": 300, "requestId": "xyz"}
```

Response is written to topic `seatadjuster/setPosition/response/gui-app`.

1. Request Seat-Adjustment from the cloud

Send MQTT message to topic `seatAdjuster/${commandName}`.

Example:
```json
{
    "appId": "seatAdjuster",      // fixed value for BfB datapoint API
    "pVer": "1.0",              // payload version of the command
    "eVer": "2.0",
    "cId": "<uuid>",            // correlation Id - Internally generated
    "cmdName": "${commandName}",  
    "ts": 0123456677,
    "p": {
      "path": "Vehicle.Cabin.Seat.Row1.Pos1.Position",
      "value": "1000" 
    }
}
```

Response is written to topic `TBD`.

  
## Release the vehicleApp to push it to the container registry
   * In order to deploy the vehicleApp you need to set the secrets on repository
     * Open `Settings`, go to `Secrets`, click on `Manage your environments and add repository secrets` and add the following secrets (button `Add Secret`):
       * EXTERNAL_OPS_DEFAULT_VCSS_ACR_USER
       * EXTERNAL_OPS_DEFAULT_VCSS_ACR_ENDPOINT (set the value e.g. to "swdceuwedevgsopscr.azurecr.io")
       * EXTERNAL_OPS_DEFAULT_VCSS_ACR_PASSWORD 
   * Open the Code page of your repository on gitHub.com and click on `Create a new release` in the Releases section on the right side
   * Enter a version and click on `Publish release`
     * Note: you can start the version with a `v` which will be removed though, e.g. "v1.0.0" will result in a "1.0.0" (see [version-without-v](https://github.com/battila7/get-version-action)).
   * The release workflow will be triggered
     * Open `Actions` on the repository and see the result

## Run the application in a Kubernetes-Cluster within the DevContainer
To run the setup within a Kubernetes Cluster within the DevContainer, scripts are provided to install prerequisites, configure the cluster and deploy the application. The steps are documented [here](https://github.com/SoftwareDefinedVehicle/vehicle-app-python-template/main/.sdv/k3d/README-k3d.md).