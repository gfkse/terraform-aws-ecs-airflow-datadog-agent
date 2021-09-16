locals {
  datadog_task_definition_file                           = "${path.module}/task-definitions/datadog.json"
  datadog_task_definition_file_dd_statsd_mapper_profiles = "${path.module}/task-definitions/dd_dogstatsd_mapper_profiles.json"
  vpc_cidr_block                                         = data.aws_vpc.selected_vpc.cidr_block_associations[0].cidr_block
  dd_api_key_parameter_arn_prefix                        = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/"
  dd_api_key_parameter_arn                               = join("", [local.dd_api_key_parameter_arn_prefix, trimprefix(var.dd_api_key_parameter_name, "/")])
  dd_api_encryption_kms_key_arn_prefix                   = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/"
  dd_api_encryption_kms_key_arn                          = (var.dd_api_encryption_kms_key_id != null && var.dd_api_encryption_kms_key_id != "") ? join("", [local.dd_api_encryption_kms_key_arn_prefix, var.dd_api_encryption_kms_key_id, "/"]) : ""
}

resource "aws_ecs_service" "datadog" {
  name                = "${var.resource_prefix}-datadog"
  cluster             = data.aws_ecs_cluster.airflow-ecs-cluster.id
  task_definition     = aws_ecs_task_definition.datadog.arn
  launch_type         = "EC2"
  desired_count       = 1
  scheduling_strategy = "REPLICA"
  platform_version    = null

  service_registries {
    registry_arn      = aws_service_discovery_service.datadog.arn
  }

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.sg_datadog_internal.id]
  }
}

resource "aws_ecs_task_definition" "datadog" {
  family                   = "${var.resource_prefix}-datadog-agent-task"
  container_definitions    = data.template_file.datadog.rendered
  memory                   = var.datadog_task_definition_memory
  cpu                      = var.datadog_task_definition_cpu
  network_mode             = var.datadog_task_definition_network_mode
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.datadog_task_execution_role.arn
  task_role_arn            = null

  volume {
    name      = "docker_sock"
    host_path = "/var/run/docker.sock"
  }

  volume {
    name      = "proc"
    host_path = "/proc/"
  }

  volume {
    name      = "cgroup"
    host_path = "/sys/fs/cgroup/"
  }

  tags = var.tags
}

data "template_file" "datadog" {
  template = var.datadog_task_definition_file == null? file(local.datadog_task_definition_file) : file(var.datadog_task_definition_file)
  vars = {
    datadog_container_cpu         = var.datadog_container_cpu
    datadog_container_memory      = var.datadog_container_memory
    dd_api_key_parameter_arn      = local.dd_api_key_parameter_arn
    dd_dogstatsd_mapper_profiles  = replace(replace(replace(data.template_file.dd_dogstatsd_mapper_profiles.rendered, "\"", "\\\""), "\n",""), " ","")
    webserver_url                 = var.webserver_url
  }
}

data "template_file" "dd_dogstatsd_mapper_profiles" {
  template = var.datadog_task_definition_file_dd_statsd_mapper_profiles == null ? file(local.datadog_task_definition_file_dd_statsd_mapper_profiles) : file(var.datadog_task_definition_file_dd_statsd_mapper_profiles)
  vars     = {}
}

resource "aws_security_group" "sg_datadog_internal" {
  name        = "${var.resource_prefix}-sg-datadog-internal"
  description = "Security group for Airflow internal traffic (Elasticache, RDS, ENIs, Datasync task, EFS mount targets)."
  vpc_id      = var.vpc_id

  ingress {
      description      = "Statsd communication"
      from_port        = 8125
      to_port          = 8125
      protocol         = "udp"
      cidr_blocks      = [local.vpc_cidr_block]
  }

  ingress {
    description      = "Container tracing"
    from_port        = 8126
    to_port          = 8126
    protocol         = "tcp"
    cidr_blocks      = [local.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}