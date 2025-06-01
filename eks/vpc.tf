locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  public_subnet_config = {
    "public-a" = {
      cidr = "10.0.1.0/24"
      az   = local.azs[0]
    }
    "public-b" = {
      cidr = "10.0.2.0/24"
      az   = local.azs[1]
    }
  }

  private_subnet_config = {
    "private-a" = {
      cidr = "10.0.10.0/24"
      az   = local.azs[0]
    }
    "private-b" = {
      cidr = "10.0.11.0/24"
      az   = local.azs[1]
    }
  }
}


resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "qrify-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "qrify-igw"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["public-a"].id

  tags = {
    Name = "qrify-nat"
  }

  depends_on = [aws_internet_gateway.igw]
}


resource "aws_subnet" "public" {
  for_each = local.public_subnet_config

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name                              = "qrify-${each.key}"
    "kubernetes.io/role/elb"          = "1"
    "kubernetes.io/cluster/qrify-eks" = "owned"
  }
}




resource "aws_subnet" "private" {
  for_each = local.private_subnet_config

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name                                  = "qrify-${each.key}"
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/cluster/qrify-eks"     = "owned"
  }
}


# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "qrify-public-rt"
  }
}

# Route table associations for public subnets
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Route table for private subnets (uses NAT gateway)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "qrify-private-rt"
  }
}

# Route table associations for private subnets
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
