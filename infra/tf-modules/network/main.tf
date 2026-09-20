locals {
  az = { for i, zone in var.availability_zones : zone => i }
}
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.tags
}
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = var.tags
}
resource "aws_subnet" "public" {
  for_each                = local.az
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[each.value]
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { "kubernetes.io/role/elb" = "1" })
}
resource "aws_subnet" "private" {
  for_each          = local.az
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[each.value]
  availability_zone = each.key
  tags              = merge(var.tags, { "kubernetes.io/role/internal-elb" = "1" })
}
resource "aws_subnet" "database" {
  for_each          = local.az
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.database_subnet_cidrs[each.value]
  availability_zone = each.key
  tags              = var.tags
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? length(var.availability_zones) : 0
  domain = "vpc"
}
resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? length(var.availability_zones) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[var.availability_zones[count.index]].id
  depends_on    = [aws_internet_gateway.this]
}
resource "aws_route_table" "private" {
  for_each = local.az
  vpc_id   = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[each.value].id
  }
}
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.this.id
}
resource "aws_route_table_association" "database" {
  for_each       = aws_subnet.database
  subnet_id      = each.value.id
  route_table_id = aws_route_table.database.id
}
resource "aws_security_group" "eks_nodes" {
  name   = "${var.name}-eks-nodes"
  vpc_id = aws_vpc.this.id
  ingress {
    self      = true
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "rds" {
  name   = "${var.name}-rds"
  vpc_id = aws_vpc.this.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
