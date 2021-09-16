output "vpc_cidr_block" {
  value = data.aws_vpc.selected_vpc.cidr_block_associations[0].cidr_block
}