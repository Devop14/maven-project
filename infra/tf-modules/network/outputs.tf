output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_ids" { value = [for az in var.availability_zones : aws_subnet.public[az].id] }
output "private_subnet_ids" { value = [for az in var.availability_zones : aws_subnet.private[az].id] }
output "database_subnet_ids" { value = [for az in var.availability_zones : aws_subnet.database[az].id] }
output "eks_node_security_group_id" { value = aws_security_group.eks_nodes.id }
output "rds_security_group_id" { value = aws_security_group.rds.id }
