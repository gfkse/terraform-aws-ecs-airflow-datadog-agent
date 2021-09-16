Copy this repo as a base for GFK open source projects. This is about legal bolier-plate, not code or CI.

[How to use this template](./TEMPLATE_README.md)

Themes you might want in this README.md:
# AWS ECS Airflow Datadog Agent Terraform module

## Features
For a given ECS cluster this module creates a service which maintains one task definition to run one datadog agent container.  
The container can be assessed by the service discovery endpoint.

## How to use it
```hcl
module "airflow_monitoring" {
  source = "./ecs_airflow_datadog_module"

  dd_api_key_parameter_name = "/datadog/apiKey"
  airflow_ecs_cluster_name  = "my-cluster"
  resource_prefix           = "airflow"
  vpc_id                    = "<vpc_id>"
  subnet_ids                = "<subnet_ids>"
  webserver_url             = "http://example.com"
}

```
## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| 
## Outputs
## References
