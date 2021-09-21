
output "service_discovery_endpoint" {
  value = "${local.service_discovery_name}.${var.resource_prefix}"
}
