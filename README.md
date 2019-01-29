# monitor-rabbitmq
AWS Cloudwatch for rabbitmq

RabbitMQ monitoring with cloudwatch namespace as `Resource/RabbitMQ`. Each metric has the name that of the queue with count that of their existing message count. A special metric named `TotalMessages` that measures total number of messages in all queues. 

## Build Docker image
```bash
$ docker build -t monitor-rabbitmq .
```

## Setup Environment variables
```bash
export RABBITMQ_URL = 'http://localhost:15672' # default
export RABBITMQ_USERNAME = 'guest' #default
export RABBITMQ_PASSWORD = 'guest' # default
export AWS_DEFAULT_REGION=us-east-1
```

## Run contaiiner on ec2-instance with cloudwatch write policy
```
$ docker run --rm -e AWS_DEFAULT_REGION -e RABBITMQ_URL -e RABBITMQ_USERNAME -e RABBITMQ_PASSWORD monitor-rabbitmq
```

## Setup a cron
Setup a cron that executes the python script as often as you want
