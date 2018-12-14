#cloud-config

runcmd:
  - yum update -y
  - yum -y install python-pip
  - pip-python install awscli
  - usermod -a -G docker ec2-user
  - service docker start
  - $(aws ecr get-login --no-include-email --region ${region})
  - docker pull ${converters_image}
  - docker run -d --restart=always --network=host --name=${name} ${converters_image} bash -c "./wait-for-it.sh ${rabbitmq_url}:5672 -s -t 30 -- dotnet VideoBattle.VideoProcessing.Console.dll"

