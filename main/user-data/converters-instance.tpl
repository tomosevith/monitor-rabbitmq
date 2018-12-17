#!/bin/bash

yum update -y
yum -y install python-pip
pip-python install awscli
usermod -a -G docker ec2-user
service docker start
$(/usr/local/bin/aws ecr get-login --no-include-email --region ${region})
docker pull ${converters_image}
docker run -d --restart=always --network=host --name=${name} ${converters_image} bash -c "/usr/local/bin/chamber exec ${name} -- && ./wait-for-it.sh ${rmq_hostname}:5672 -s -t 30 -- dotnet VideoBattle.VideoProcessing.Console.dll"


