# RMQ Cluster on AWS

This project contains fully configured [RabbitMQ](https://www.rabbitmq.com/) cluster with autoscaling and service discovery ability. To provision necessary resources you need at least developer access to the [AWS console].

Tools:
 * [terraform](https://www.terraform.io/downloads.html)
 * [aws cli](https://aws.amazon.com/cli/)

## Deploying new cluster

First you need to initialize project and create new workspace, it's name is used in resource naming. Default workspace is just for testing new configuration. By default it uses t2.medium instances with count=2. This can be overwiretten with `terraform.tfvars` file:

```
$ terraform init

Initializing the backend...

Initializing provider plugins...
...
$ terraform workspace new example
```

To update existing configuration select workspace from the list:

```
$ terraform workspace list
* default
  example
$ terraform workspace select example
```

For the names i've used terraform interpolation and local variable `name`:

```
locals {
  name = "${terraform.env == "default" ? "rmq-${random_string.rmq_name.result}" : "rmq-${random_string.rmq_name.result}-${terraform.env}"}"
}
```

where `random_string.rmq_name.result` is for some sort of randomness:

```
resource "random_string" "rmq_name" {
  length  = 6
  special = false
  upper   = false
}
```

After running apply terraform will create all necessary resources: security groups, policies, launch conigs, instances and load balancer:

```
$ terraform apply
...
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

rabbitmq_endpoint = https://rmq-ela1qv-example-elb-1215621613.us-east-1.elb.amazonaws.com
```

That's it, now RMQ is accessible by the url above. It's better to set appropriate DNS name, because SSL certificate is generated for the `example.com` domain.

Admin password can be obtained by running:

```
$ terraform state show random_string.rmq_admin_password
```
