# docker login ghcr.io 

Import-Module $PSScriptRoot/Sdv.psm1 -Force

foreach($Component in (Find-SdvVehicleApp | Get-SdvComponent)) {
    $ImageName = ("{0}_base_amd64" -f $Component.Name)
    $Dockerfile = Join-Path $Component.Folder -ChildPath "Dockerfile.base"
    $DockerContext = $Component.DockerFolder
    docker build -t ghcr.io/softwaredefinedvehicle/vehicle-app-python-template/$ImageName -f $Dockerfile $DockerContext
    docker push ghcr.io/softwaredefinedvehicle/vehicle-app-python-template/$ImageName
}



# docker build -t ghcr.io/softwaredefinedvehicle/vehicle-app-python-template/vehicleapi_base_amd64 -f vehicleapi/Dockerfile.base ./vehicleapi
# docker push ghcr.io/softwaredefinedvehicle/vehicle-app-python-template/vehicleapi_base_amd64

# docker build -t vehicleapi -f vehicleapi/Dockerfile .