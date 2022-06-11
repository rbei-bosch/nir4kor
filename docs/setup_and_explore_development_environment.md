# Setup and Explore Development Environment

The following information describes how to setup and configure the Development Container (DevContainer), and how to build, customize and test the sample vehicleApp that is included in this repository. You will learn how to use the vehicleApp SDK, how to interact with the vehicle API and how to do CI/CD using the pre-configured GitHub workflows that come with the repository.

Once you have completed all steps you will have a solid understanding of the Development Workflow and you will be able to reuse this Template Repository for your own VehicleApp develpment project.

## VehicleApp Development with Visual Studio Code
Visual Studio Code [Development Containers](https://code.visualstudio.com/docs/remote/create-dev-container#:~:text=%20Create%20a%20development%20container%20%201%20Path,additional%20software%20in%20your%20dev%20container.%20More%20) allows to package a complete vehicleApp development environment including Visual Studio Code extensions, vehicleApp SDK, vehicleApp runtime and all other development & testing tools into a container that is then started within your Visual Studio Code session.

To be able to use the DevContainer, you have to make sure to fulfill the following prerequisites:

### System prerequisites
* Install Docker Engine / [Docker Desktop](https://www.docker.com/products/docker-desktop)
* Install [Visual Studio Code](https://code.visualstudio.com)
* Add [Remote-Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension via the marketplace or using the command line
   ```
   code --install-extension ms-vscode-remote.remote-containers
   ```

### Proxy Configuration
> Disclaimer: Non proxy configuration is used by default

If you are working behind a corporate proxy add the following environment variable so that the DevContainer will use the correct proxy settings.

#### Windows:
1. Edit environment variables for your account
2. Create an environment variable with name the `DEVCONTAINER_PROXY` and with the value `.Proxy` for your account
   * Don't forget (dot) in value of the environment variable
3. If you are using a different Port than 3128 for your Proxy, you have to set another environment variable as follows:
   *  DEVCONTAINER_PROXY_PORT=<PortNumber>
4. Restart Visual Studio Code to pick up new environment variable

#### macOS & Linux:
```
echo "export DEVCONTAINER_PROXY=.Proxy" >> ~/.bash_profile
source ~/.bash_profile
```

### Proxy Troubleshooting

If you experience issues during initial DevContainer build and you want to start over, then you want to make sure you clean all images and volumes in Docker Desktop, otherwise cache might be used. Use the Docker Desktop UI to remove all volumes and containers.

In case the DevContainer is still not working, check if proxy settings are set correctly in the `.docker\config.json` file in User profile directory, see [Docker Documentation](https://docs.docker.com/network/proxy/) for more details.

## Use Template Repository
Create your own repository copy from this Template Repository by clicking the green button `Use this template`. You don't have to include all branches.

The name `MyOrg/MyFirstVehicleApp` is used as a reference during the rest of document.

For more information on Template Repositories take a look at this [GitHub Tutorial](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template)

## Start VehicleApp DevContainer
With following steps you will clone and set up your development environment using the preconfigured DevContainer.

1. Start Visual Studio Code
2. Press <kbd>F1</kbd> and run the command `Remote-Containers: Clone Repository within Container Volume...`
3. Select `Clone a repository from GitHub in a Container Volume` and choose the repository / branch to clone
4. Enter the GitHub organization and repository name (e.g. `MyOrg/MyFirstVehicleApp`) and select the repository from the list
5. Select the branch to clone from the list

The first time you initialize the container it will take about 10 minutes to build the image and provision the tools inside the container.

> If the development container fails to build successfully (e.g. due to network issues) then wait for the current build to finish and then press <kbd>F1</kbd> and run the command `Remote-Containers: Rebuild Container Without Cache`

> When opening the DevContainer for the first time, the following steps are necessary
   - A manual reload of the dapr extension is required. (Note: the reload button appears next to Dapr extension in extension menue).

## Running VAL services
The Vehicle Abstraction Layer (VAL) services are required to interact with vehicle data and methods.

### Run VAL services as tasks in Visual Studio Code (recommended)
The VAL services will start automatically when opening the folder in Visual Studio Code. The configuration for that can be found in ```./.vscode/tasks.json```. Each service is configured as one background task with the ```runOn```-property configured as ```folderOpen```.  When opening the workspace for the first time, Visual Studio Code asks if it should be allowed to run tasks on folderOpen. This approval can be also set by pressing F1 and typing *Manage Automatic tasks in folder* -> *Allow automatic tasks in folder*.

More information about tasks in Visual Studio Code can be found [here](https://code.visualstudio.com/docs/editor/tasks).

It's also possible to start/stop tasks manually by pressing F1 and typing *Run Task* or *Terminate Task* and select the respective task to run/stop.

The running tasks are display in the Terminal-Window one-by-one. To reopen that view, you can press F1 and type *Show running tasks*. In that view, you can access the logs of the respective task.

### Run VAL services manually
To run the VAL services manually, it's possible to call a bash script that starts the service. The scripts are located in ```./.vscode/scripts/run-*.sh```.

### Using Vehicle Databroker CLI
The interact with a running instance of the Vehicle Data Broker, a CLI tool is provided. It can be started by running the script ```./.vscode/scripts/run-vehicledatabroker-cli.sh```. To be able to use the tool, the *Vehicle Data Broker* needs to be running.

### Using different version of VAL services
   - Update ```./prerequisite_settings.json```
   - Restart the tasks for the services


## Start and test VehicleApp
Now that your DevContainer is up and running, it is time to take a look at what's inside:


* VehicleApp - This sample app is a basic blueprint and illustrates how to interact with the VAL Services and the VehicleApp SDK.
* Mosquitto MQTT Broker - The broker allows for interaction with other vehicleApps or the cloud and is used by the VehicleApp. The MQTT broker is running inside a docker image which is started automatically after starting the DevContainer.

There are many more tools coming with the DevContainer and you can learn more about them in the [extended Developer Documentation](dev_further_topics.md).


### Start and check VehicleApp

Let's start the sample vehicleApp to verify that you receive actual data from the API.

Open a new terminal and start the vehicleApp with the following command:
```bash
dapr run --app-id seatadjuster --app-protocol grpc --app-port 50008 --config ./.dapr/config.yaml --components-path ./.dapr/components  python3 ./src/run.py
```
Once the vehicleApp is started, you can expect to receive the Current Position of the Vehicle Seat, which should be reported as 420.

You will see messages such as
```
== APP == 04/06/2022 07:31:58 AM - __main__ - INFO - Current Position of the Vehicle Seat is: {'position': 420}
```

To stop the vehicleApp instance: close the terminal window by hitting <kbd>Ctrl + C</kbd>.

### Debug VehicleApp

After VAL Services and vehicleApp are running successfully, let's start a debug session for the vehicleApp as next step.

* Press <kbd>F5</kbd> to start the vehicleApp to start a debug session and see the log output on the `DEBUG CONSOLE`
* Open the main python file `src/run.py` file and set a breakpoint in `line 39`

In the next step you will use a mqtt message to trigger this breakpoint.

### Send MQTT messages to VehicleApp

Let's send a message to your VehicleApp using the mqtt broker that is running in the background.

* Make sure, Vehicle Api Mock and Seat Adjuster App are running.
* Open `VSMqtt` extension in Visual Studio Code and connect to `mosquitto (local)`
* Set `Subscribe Topic` = `seatadjuster/setPosition/response/gui-app` and click subscribe.
* Set `Publish Topic` = `seatadjuster/setPosition/request/gui-app`
* Set and publish a dummy payload:

   ```json
   {"position": 300, "requestId": "xyz"}
   ```

* Now your breakpoint in the VehicleApp gets hit and you can inspect everything in your debug session
* After resuming execution (<kbd>F5</kbd>), a response from your VehicleApp is published to the response topic
* You can see the response in the MQTT window.

## Trigger your Github Workflows
GitHub workflows are used to build the container image for the vehicleApp, run unit and integration tests, collect the test results and create a release documentation and publish the vehicleApp. A detailed description of the workflow you can find [here](https://github.com/SoftwareDefinedVehicle/sdv-velositas-docs/blob/main/docs/vehicle_app_releases.md).

Every time you commit to the repository a set of wokflows is executed automatically.

![Reference Architecture](assets/publish_container.png)

### Run GitHub Workflow
* Make modification to your file, e.g. remove the last empty line from `src/run.py`
* Commit you change
   ```bash
   git add .
   git commit -m "removed emtpy line"
   ```
* Push
   ```bash
   git push
   ```
* Open your git repository in your favorite browser
* Navigate to `Actions` and go to [CI Workflow](../actions/workflows/ci.yml)
* Check Workflow Output, it should look like this:
![](assets/ci-workflow-success.png)

## Build you first release
Now that the `CI Workflow` was successful, you are ready to build your first release. Your goal is to build a ready-to-deploy container image.

### Release the vehicleApp to push it to the container registry
* In order to deploy the vehicleApp you need to set the secrets on repository
  * Open `Settings`, go to `Secrets`, click on `Manage your environments and add repository secrets` and add the following secrets (button `Add Secret`):
    * CONTAINER_REGISTRY_ENDPOINT
    * CONTAINER_REGISTRY_USER
    * CONTAINER_REGISTRY_PASSWORD
* Open the `Code` page of your repository on gitHub.com and click on `Create a new release` in the Releases section on the right side
* Enter a version and click on `Publish release`
  * Note: you can start the verion with a `v` which will be removed though, e.g. "v1.0.0" will result in a "1.0.0" (see [vesion-without-v](https://github.com/battila7/get-version-action)).
* The release workflow will be triggered
  * Open `Actions` on the repoitory and see the result

## Next steps

* [Run the application in a Kubernetes-Cluster within the DevContainer](scripts/k3d/README-k3d.md)
* [Building multi-stage image](multi-stage%20build/README.md)
* [Learn more about the DevContainer internals and tools that come with it](dev_further_topics.md)
