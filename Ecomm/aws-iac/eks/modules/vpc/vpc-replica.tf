# Replica VPC
# resource "aws_vpc" "replica_vpc" {
#   provider   = aws.replica
#   cidr_block = "10.20.0.0/16"
#   enable_dns_support   = true
#   enable_dns_hostnames = true

#   tags = {
#     Name = "replica-vpc"
#   }
# }

# Replica private subnets (across two AZs)
# resource "aws_subnet" "replica_private_subnets" {
#   provider          = aws.replica
#   for_each          = {
#     "a" = "10.20.1.0/24"
#     "c" = "10.20.2.0/24"
#   }
#   vpc_id            = aws_vpc.replica_vpc.id
#   cidr_block        = each.value
#   availability_zone = "us-west-1${each.key}"
#   map_public_ip_on_launch = false

#   tags = {
#     Name = "replica-private-${each.key}"
#   }
# }

# resource "aws_db_subnet_group" "replica_db_subnet_group" {
#   provider   = aws.replica
#   name       = "${var.db_instance_identifier}-replica-subnet-group"
#   subnet_ids = [for s in aws_subnet.replica_private_subnets : s.id]

#   tags = {
#     Name = "${var.db_instance_identifier}-replica-subnet-group"
#   }
# }
