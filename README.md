# AWS ECS Airflow Datadog Agent Terraform module

## Features
For a given ECS cluster this module creates a service which maintains one task definition to run one datadog agent container.  
The container can be assessed by the service discovery endpoint.

The default configuration is focused to monitor Airflow.

## How to use it
Example:
```hcl
module "airflow_monitoring" {
  source = "github.com/gfkse/ecs_airflow_datadog_module?ref=<x.y.z>"

  dd_api_key_parameter_name = "/datadog/apiKey"
  airflow_ecs_cluster_name  = "my-cluster"
  resource_prefix           = "airflow"
  vpc_id                    = "<vpc_id>"
  subnet_ids                = "<subnet_ids>"
  service_endpoint_url      = "http://example.com"
}
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_service.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_policy.datadog_task_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.datadog_task_execution_role_policy_with_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.datadog_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.datadog_tasks_execution_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.datadog_tasks_execution_role_policy_attachment_with_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.sg_datadog_internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_service_discovery_private_dns_namespace.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) | resource |
| [aws_service_discovery_service.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecs_cluster.airflow-ecs-cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_vpc.selected_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [template_file.dd_dogstatsd_mapper_profiles](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_airflow_ecs_cluster_name"></a> [airflow\_ecs\_cluster\_name](#input\_airflow\_ecs\_cluster\_name) | Name of the airflow ECS cluster for which the datadog monitoring will be attached. | `string` | n/a | yes |
| <a name="input_datadog_container_cpu"></a> [datadog\_container\_cpu](#input\_datadog\_container\_cpu) | Desired container cpu. | `number` | `10` | no |
| <a name="input_datadog_container_memory"></a> [datadog\_container\_memory](#input\_datadog\_container\_memory) | Desired container memory. | `number` | `256` | no |
| <a name="input_datadog_task_definition"></a> [datadog\_task\_definition](#input\_datadog\_task\_definition) | https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ecs-taskdefinition-containerdefinitions.html | `list(object({}))` | `null` | no |
| <a name="input_datadog_task_definition_cpu"></a> [datadog\_task\_definition\_cpu](#input\_datadog\_task\_definition\_cpu) | Desired task definition cpu. | `string` | `null` | no |
| <a name="input_datadog_task_definition_file_dd_statsd_mapper_profiles"></a> [datadog\_task\_definition\_file\_dd\_statsd\_mapper\_profiles](#input\_datadog\_task\_definition\_file\_dd\_statsd\_mapper\_profiles) | https://docs.datadoghq.com/developers/dogstatsd/dogstatsd_mapper/ | `string` | `null` | no |
| <a name="input_datadog_task_definition_memory"></a> [datadog\_task\_definition\_memory](#input\_datadog\_task\_definition\_memory) | Desired task definition memory. | `string` | `null` | no |
| <a name="input_datadog_task_definition_network_mode"></a> [datadog\_task\_definition\_network\_mode](#input\_datadog\_task\_definition\_network\_mode) | n/a | `string` | `"awsvpc"` | no |
| <a name="input_dd_api_encryption_kms_key_id"></a> [dd\_api\_encryption\_kms\_key\_id](#input\_dd\_api\_encryption\_kms\_key\_id) | Required only if your secret uses a custom KMS key and not the default key. The ARN for your custom key should be added as a resource. | `string` | `""` | no |
| <a name="input_dd_api_key_parameter_name"></a> [dd\_api\_key\_parameter\_name](#input\_dd\_api\_key\_parameter\_name) | The name of the parameter store secret containing the key to access Datadog API. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix name for the resources. | `string` | n/a | yes |
| <a name="input_service_endpoint_url"></a> [service\_endpoint\_url](#input\_service\_endpoint\_url) | The url of the service to check whether it can connect and is healthy: https://docs.datadoghq.com/integrations/airflow/?tab=containerized#configuration | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The VPC's private Subnet IDs, where rds, elasticache, alb and ecs cluster will reside. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resources in the module. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of VPC, where rds, elasticache, alb and ecs cluster will reside. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_discovery_endpoint"></a> [service\_discovery\_endpoint](#output\_service\_discovery\_endpoint) | n/a |
