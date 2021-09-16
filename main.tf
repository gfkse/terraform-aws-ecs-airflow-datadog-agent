locals {
  dd_statsd_mapper_profiles_file = "${path.module}/datadog_default_dogstatsd_mapper_profiles.json"
  vpc_cidr_block                 = data.aws_vpc.selected_vpc.cidr_block_associations[0].cidr_block
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
    registry_arn = aws_service_discovery_service.datadog.arn
  }

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.sg_datadog_internal.id]
  }

  tags = var.tags
}

resource "aws_ecs_task_definition" "datadog" {
  family                   = "${var.resource_prefix}-datadog-agent-task"
  container_definitions    = var.datadog_task_definition == null ? jsonencode(local.container_definition) : jsonencode(var.datadog_task_definition)
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

resource "aws_security_group" "sg_datadog_internal" {
  name        = "${var.resource_prefix}-sg-datadog-internal"
  description = "Security group for Airflow internal traffic (Elasticache, RDS, ENIs, Datasync task, EFS mount targets)."
  vpc_id      = var.vpc_id

  ingress {
    description = "Statsd communication"
    from_port   = 8125
    to_port     = 8125
    protocol    = "udp"
    cidr_blocks = [local.vpc_cidr_block]
  }

  ingress {
    description = "Container tracing"
    from_port   = 8126
    to_port     = 8126
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}