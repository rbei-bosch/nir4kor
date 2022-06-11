#!/bin/sh

# sudo apt install jq
echo "Script executed from: ${PWD}"
temp=$OTA_Secret
# $temp | jq '.CONTAINER_REGISTRY'
CONTAINER_REGISTRY=$(echo $temp | jq '.CONTAINER_REGISTRY')
REGISTRY_USER=$(echo $temp | jq '.REGISTRY_USER')
REGISTRY_PASSWORD=$(echo $temp | jq '.REGISTRY_PASSWORD')

echo "CONTAINER_REGISTRY=$CONTAINER_REGISTRY" >> $GITHUB_ENV
echo "REGISTRY_USER=$REGISTRY_USER" >> $GITHUB_ENV
echo "REGISTRY_PASSWORD=$REGISTRY_PASSWORD" >> $GITHUB_ENV

# echo "CONTAINER_REGISTRY >> $CONTAINER_REGISTRY"
# echo "REGISTRY_USER>> $REGISTRY_USER"
# echo "REGISTRY_PASSWORD >>$REGISTRY_PASSWORD"
# jq -n --arg appname $temp > process.json
# jq '.CONTAINER_REGISTRY' process.json
# $OTA_Secret=$temp
# myvar=$OTA_Secret
# size=${#myvar} 
# echo "TEST_OTA_CRED: ${#OTA_Secret}"
# echo "Size: $size"
# echo  jq '.' $OTA_Secret
# echo "temp >>> $temp"
printenv

# // let raw_data = $OTA_Secret
# // console.log(raw_data)
# // console.log(typeof raw_data);
