data "aws_ecs_cluster" "airflow-ecs-cluster" {
  cluster_name = var.airflow_ecs_cluster_name
}

data "aws_vpc" "selected_vpc" {
  id = var.vpc_id
}
