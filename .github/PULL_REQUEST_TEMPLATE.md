# Description

<!--
Please explain the changes you've made.
-->

## Azure DevOps PBI/Task reference

<!--
We strive to have all PR being opened based on an Azure DevOps PBI/Task.
-->

Please reference the PBI/Task this PR will close: AB#_[PBI/Task number]_

## Checklist

Depending on where you made changes in the template repository, make sure you have the following items checked.

### Extended Vehicle App

* [ ] Vehicle App can be started with dapr run and is connecting to vehicle data broker
* [ ] Vehicle App app can process MQTT messages and call the seat service
* [ ] Vehicle App app can be deployed to local K3D and is running
* [ ] Created/updated tests, if necessary. Code Coverage percentage on new code shall be >= 70%.
* [ ] Unit tests passing
* [ ] Integration tests passing
* [ ] CI/CD workflows successful
* [ ] Extended the documentation (e.g. README.md)

### Extended DevContainer

* [ ] Devcontainer can be opened successfully
* [ ] Devcontainer can be opened successfully behind a corporate proxy
* [ ] Devcontainer can be re-built successfully
* [ ] Extended the documentation (e.g. README.md)

### Extended build/release workflows

* [ ] Build workflow is passing
* [ ] Release workflow is passing
* [ ] Extended the documentation (e.g. README.md)

### Extended K3D setup

* [ ] Vehicle App app can be deployed to local K3D and is running
* [ ] Integration tests can be deployed locally to K3D and are passing
* [ ] Extended the documentation (e.g. README.md)
