# Building multi-stage image (Optional)
There might be a need from developer to use multi-stage build. Using such an approach, would speed up the completion of CI Workflow, in case python wheels have to be compiled. To achieve that below solution provides prebuild base image, which does not need to be build on every CI run.

## How does it work?

**Files:**
* seatadjuster (Dockerfile, Dockerfile.base)
  * Base image is build and pushed to the git repository. While building application image (Dockerfile), prebuilt base image will be used.
* vehicleapi (Dockerfile, Dockerfile.base)
  * Base image is build and pushed to the git repository. While building application image (Dockerfile), prebuilt base image will be used.
* workflow (build_base_images.yml)

**Get it running:**
* Copy workflow file (build_base_images.yml) to ```.github/workflows```
* Create Dockerfile and Dockerfile.base for **seatadjuster** files in: ```/src```
  <details>
      <summary> Dockerfile </summary>

        FROM ghcr.io/softwaredefinedvehicle/vehicle-app-python-template/client_base

        RUN apt-get update
        RUN apt-get upgrade -y

        ADD ./* $HOME/src/
        WORKDIR /src
        RUN pip3 install -r requirements-dev.txt

        ENTRYPOINT ["python"]
        CMD ["seatadjuster.py"]

  </details>
  <details>
      <summary> Dockerfile.base </summary>

        FROM python:3.9-slim-bullseye

        RUN apt-get update
        RUN apt-get upgrade -y

        ADD ./* $HOME/src/
        WORKDIR /src
        RUN pip3 install -r requirements.txt

        LABEL org.opencontainers.image.source="https://github.com/softwaredefinedvehicle/vehicle-app-python-template"

  </details>
* Create Dockerfile and Dockerfile.base for **vehicleapi** files in: ```/src/vehicle_sdk/vehicle_api_mock```
  <details>
      <summary> Dockerfile </summary>

        FROM ghcr.io/softwaredefinedvehicle/vehicle-app-python-template/client_base

        RUN apt-get update
        RUN apt-get upgrade -y

        ADD ./* $HOME/src/
        WORKDIR /src
        RUN pip3 install -r requirements-dev.txt

        EXPOSE 50051

        ENTRYPOINT ["python"]
        CMD ["seatadjuster.py"]


  </details>
  <details>
      <summary> Dockerfile.base </summary>

        FROM python:3.9-slim-bullseye

        RUN apt-get update
        RUN apt-get upgrade -y

        WORKDIR /vehicleapi
        ADD ./* $HOME/vehicleapi/
        RUN pip3 install -r requirements.txt

        LABEL org.opencontainers.image.source="https://github.com/softwaredefinedvehicle/vehicle-app-python-template"



  </details>
* Login to Github platform and execute the workflow

## Troubleshooting:
In case of building multi-stage images locally, Docker and Git needs to be configured.

**Docker/ Git configuration:**
* Generate token: ```Github -> UserAccount -> Settings -> Developer Settings -> Personal Access token```
* Once token is issued, click: ```Configure SSO -> Authorize -> Software Defined Vehicle```
* In console type: ```docker login ghcr.io```
* Use generated token to authenticate
* To build file locally, find commands in: ```scripts/k3d/03_deploy.k3d.sh```
