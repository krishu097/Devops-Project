output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.gmk-vpc.id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "cluster_security_group_id" {
  description = "ID of the cluster security group"
  value       = aws_security_group.cluster.id
}

output "nodes_security_group_id" {
  description = "ID of the nodes security group"
  value       = aws_security_group.nodes.id
}

# output "mysql_security_group_id" {
#   description = "Name of the RDS DB subnet group"
#   value       = aws_security_group.mysql.id
# }

output "db_subnet_group_name" {
  description = "Name of the RDS DB subnet group"
  value       = aws_db_subnet_group.db_subnet.name
}

output "replica_db_subnet_group_name" {
  description = "Name of the RDS Replica DB subnet group"
  value       = aws_db_subnet_group.replica_db_subnet_group.name
}

