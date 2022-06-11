FROM ghcr.io/softwaredefinedvehicle/vehicle-app-python-template/client_base

RUN apt-get update 
RUN apt-get upgrade -y

COPY ./src /src
WORKDIR /src
RUN pip3 install -r requirements.txt

ENTRYPOINT ["python"]
CMD ["client.py"]