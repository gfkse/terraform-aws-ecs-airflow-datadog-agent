data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "template_file" "dd_dogstatsd_mapper_profiles" {
  template = var.datadog_task_definition_file_dd_statsd_mapper_profiles == null ? file(local.dd_statsd_mapper_profiles_file) : file(var.datadog_task_definition_file_dd_statsd_mapper_profiles)
}

locals {
  dd_api_key_param_arn_prefix   = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/"
  dd_api_key_param_arn          = join("", [local.dd_api_key_param_arn_prefix, trimprefix(var.dd_api_key_parameter_name, "/")])
  dd_api_enc_kms_key_arn_prefix = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/"
  dd_api_enc_kms_key_arn        = (var.dd_api_encryption_kms_key_id != null && var.dd_api_encryption_kms_key_id != "") ? join("", [local.dd_api_enc_kms_key_arn_prefix, var.dd_api_encryption_kms_key_id, "/"]) : ""

  container_definition = [
    {
      name      = "datadog-agent",
      image     = var.datadog_agent_image,
      essential = true,
      cpu       = var.datadog_container_cpu,
      memory    = var.datadog_container_memory,
      portMappings = [
        {
          hostPort      = 8125,
          protocol      = "udp",
          containerPort = 8125
        },
        {
          hostPort      = 8126,
          protocol      = "tcp",
          containerPort = 8126
        },
        {
          hostPort      = 5555,
          protocol      = "tcp",
          containerPort = 5555
        }
      ],
      secrets = [
        {
          name      = "DD_API_KEY",
          valueFrom = local.dd_api_key_param_arn
        }
      ],
      environment = [
        {
          name : "DD_LOGS_ENABLED",
          value : "true"
        },
        {
          name  = "DD_SITE",
          value = "datadoghq.eu"
        },
        {
          name  = "DD_DOGSTATSD_NON_LOCAL_TRAFFIC",
          value = "true"
        },
        {
          name  = "DD_DOGSTATSD_PORT",
          value = "8125"
        },
        {
          name  = "DD_DOGSTATSD_DISABLE",
          value = "false"
        },
        {
          name  = "DD_DOGSTATSD_METRICS_STATS_ENABLE",
          value = "false"
        },
        {
          name  = "DD_DOGSTATSD_MAPPER_PROFILES",
          value = replace(replace(data.template_file.dd_dogstatsd_mapper_profiles.rendered, "\n", ""), " ", "")
        },
        {
          name  = "DD_HEALTH_PORT",
          value = "5555"

        }
      ],
      mountPoints = [
        {
          containerPath = "/var/run/docker.sock",
          sourceVolume  = "docker_sock",
          readOnly      = true
        },
        {
          containerPath = "/host/sys/fs/cgroup",
          sourceVolume  = "cgroup",
          readOnly      = true
        },
        {
          containerPath = "/host/proc",
          sourceVolume  = "proc",
          readOnly      = true
        }
      ],
      dockerLabels = {
        "com.datadoghq.ad.instances"    = "[{\"url\": \"${var.service_endpoint_url}\"}]",
        "com.datadoghq.ad.check_names"  = "[\"airflow\"]",
        "com.datadoghq.ad.init_configs" = "[{}]"
      },
      logConfiguration = {
          "logDriver" = "awslogs",
          "options" = {
              "awslogs-create-group" = "true",
              "awslogs-group" = "/ecs/${var.service_endpoint_url}",
              "awslogs-region" = var.region,
              "awslogs-stream-prefix" = "ecs"
          },
          "secretOptions" = []
      }
    }
  ]
}