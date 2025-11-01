resource "aws_vpc" "gmk-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "gmk-ig" {
  vpc_id = aws_vpc.gmk-vpc.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-igw"
  })
}

# Public Subnets - Simple CIDR blocks
resource "aws_subnet" "public" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.gmk-vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 2, count.index)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                     = "${var.name_prefix}-public-${var.azs[count.index]}"
    "kubernetes.io/role/elb" = "1"
  })
}


resource "aws_subnet" "private" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.gmk-vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 2, count.index + length(var.azs))
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, {
    Name                              = "${var.name_prefix}-private-${var.azs[count.index]}"
    "kubernetes.io/role/internal-elb" = "1"
  })
}

# NAT Gateways
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? length(var.azs) : 0
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-${var.azs[count.index]}"
  })
}

resource "aws_nat_gateway" "gmk-nat" {
  count         = var.enable_nat_gateway ? length(var.azs) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-gw-${var.azs[count.index]}"
  })
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.gmk-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gmk-ig.id
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = length(var.azs)
  vpc_id = aws_vpc.gmk-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.one_nat_gateway_per_az ? aws_nat_gateway.gmk-nat[count.index].id : aws_nat_gateway.gmk-nat[0].id
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-rt-${var.azs[count.index]}"
  })
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

###############################################################
resource "aws_db_subnet_group" "db_subnet" {
  name       = lower("${var.name_prefix}-db-subnet-group")
  subnet_ids = aws_subnet.private[*].id
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-db-subnet-group"
  })
}
###########################################################
