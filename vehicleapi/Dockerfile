FROM ghcr.io/softwaredefinedvehicle/vehicle-app-python-template/vehicleapi_base

RUN apt-get update 
RUN apt-get upgrade

WORKDIR /vehicleapi
COPY . .
RUN pip3 install -r requirements.txt

EXPOSE 50051

ENTRYPOINT ["python"]
CMD ["vehicleapi.py"]