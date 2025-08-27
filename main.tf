# ==========================
# VPC
# ==========================
resource "aws_vpc" "kcvpc" {
  cidr_block = var.vpc_cidr
  tags       = { Name = "KCVPC" }
}

# ==========================
# Subnets
# ==========================
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.kcvpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "PublicSubnet" }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.kcvpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "eu-west-1a"
  tags              = { Name = "PrivateSubnet" }
}

# ==========================
# Internet Gateway
# ==========================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.kcvpc.id
  tags   = { Name = "KCIGW" }
}

# ==========================
# Public Route Table
# ==========================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.kcvpc.id
  tags   = { Name = "PublicRouteTable" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ==========================
# NAT Gateway + Elastic IP
# ==========================
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
  tags          = { Name = "KCNAT" }
}

# ==========================
# Private Route Table
# ==========================
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.kcvpc.id
  tags   = { Name = "PrivateRouteTable" }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# ==========================
# Security Groups
# ==========================
resource "aws_security_group" "public_sg" {
  name        = "PublicSG"
  description = "Allow web + SSH"
  vpc_id      = aws_vpc.kcvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  name        = "PrivateSG"
  description = "Allow DB + SSH from PublicSG"
  vpc_id      = aws_vpc.kcvpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==========================
# Latest Ubuntu 22.04 LTS AMI
# ==========================
data "aws_ssm_parameter" "ubuntu_22_04" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

# ==========================
# EC2 Instances
# ==========================
resource "aws_instance" "public_ec2" {
  ami                    = data.aws_ssm_parameter.ubuntu_22_04.value
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  tags = { Name = "PublicEC2" }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "private_ec2" {
  ami                    = data.aws_ssm_parameter.ubuntu_22_04.value
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  tags = { Name = "PrivateEC2" }

  lifecycle {
    create_before_destroy = true
  }
}

# ==========================
# Outputs
# ==========================
output "public_ec2_ip" {
  description = "Public IP of the public EC2"
  value       = aws_instance.public_ec2.public_ip
}

output "private_ec2_id" {
  description = "ID of the private EC2 instance"
  value       = aws_instance.private_ec2.id
}

output "ubuntu_ami_id" {
  description = "The AMI ID Terraform will use"
  value       = data.aws_ssm_parameter.ubuntu_22_04.value
  sensitive   = true
}
