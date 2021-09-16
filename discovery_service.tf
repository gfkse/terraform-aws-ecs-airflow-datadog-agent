resource "aws_service_discovery_private_dns_namespace" "datadog" {
  name        = var.resource_prefix
  description = "Namespace for the airflow cluster ${var.resource_prefix}"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "datadog" {
  name = "datadog-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.datadog.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}