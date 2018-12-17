#!/bin/bash

yum update -y
yum -y install python-pip
pip-python install awscli
usermod -a -G docker ec2-user
service docker start

export SSM_PROJECT_NAME=${project_name}
export SSM_SERVICE_NAME=${service_name}
export USE_AWS_PARAMETER_STORE=1
export AWS_DEFAULT_REGION=${region}
export KMS_KEY_ALIAS=${kms_keys_alias}

eval $(/usr/local/bin/aws ecr get-login --no-include-email --region ${region})

docker pull ${converters_image}

docker run -d --restart=always --name=${service_name} --network=host --log-opt max-size=500m -e SSM_PROJECT_NAME -e SSM_SERVICE_NAME -e USE_AWS_PARAMETER_STORE -e AWS_DEFAULT_REGION ${converters_image} bash -c "dotnet VideoBattle.VideoProcessing.Console.dll"

