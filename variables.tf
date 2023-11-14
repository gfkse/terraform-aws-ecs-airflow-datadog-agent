variable "region" {
  type = string
}

variable "dd_api_key_parameter_name" {
  type        = string
  description = "The name of the parameter store secret containing the key to access Datadog API."
}

variable "dd_api_encryption_kms_key_id" {
  type        = string
  description = "Required only if your secret uses a custom KMS key and not the default key. The ARN for your custom key should be added as a resource."
  default     = ""
}

variable "airflow_ecs_cluster_name" {
  type        = string
  description = "Name of the airflow ECS cluster for which the datadog monitoring will be attached."
}

variable "datadog_task_definition_memory" {
  type        = string
  description = "Desired task definition memory."
  default     = null
}

variable "datadog_task_definition_cpu" {
  type        = string
  description = "Desired task definition cpu."
  default     = null
}

variable "datadog_container_memory" {
  type        = number
  description = "Desired container memory."
  default     = 256
}

variable "datadog_container_cpu" {
  type        = number
  description = "Desired container cpu."
  default     = 10
}

variable "datadog_task_definition_network_mode" {
  default = "awsvpc"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources in the module."
  default     = {}
}

variable "resource_prefix" {
  type        = string
  description = "Prefix name for the resources."
}

variable "service_endpoint_url" {
  type        = string
  description = "The url of the service to check whether it can connect and is healthy: https://docs.datadoghq.com/integrations/airflow/?tab=containerized#configuration"
}

variable "vpc_id" {
  type        = string
  description = "ID of VPC, where rds, elasticache, alb and ecs cluster will reside."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The VPC's private Subnet IDs, where rds, elasticache, alb and ecs cluster will reside."
}

variable "datadog_task_definition" {
  type        = list(object({}))
  description = "https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ecs-taskdefinition-containerdefinitions.html"
  default     = null
}

variable "datadog_task_definition_file_dd_statsd_mapper_profiles" {
  type        = string
  description = "https://docs.datadoghq.com/developers/dogstatsd/dogstatsd_mapper/"
  default     = null
}

variable "datadog_agent_image" {
  type        = string
  description = "Datadog agent image to be used. You might be using a fixed version for production environments."
  default     = "datadog/agent:7"
}

variable "datadog_log_group_name" {
  type        = string
  description = "This name will be used to form the aws cloudwatch group name to store the datadog agent container related logs."
  default     = "datadog_agent"
}