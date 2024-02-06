provider "aws" {
  region = var.region
}

resource "aws_vpc" "studi_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "studi-vpc"
  }
}

resource "aws_internet_gateway" "studi_igw" {
  vpc_id = aws_vpc.studi_vpc.id
  tags = {
    Name = "studi-igw"
  }
}

resource "aws_route_table" "studi_rt" {
  vpc_id = aws_vpc.studi_vpc.id
  route {
    cidr_block = "0.0.0.0/0" # Route everything to the internet gateway
    gateway_id = aws_internet_gateway.studi_igw.id
  }
  tags = {
    Name = "studi-rt"
  }
}

resource "aws_subnet" "subnet_front" {
  vpc_id     = aws_vpc.studi_vpc.id
  cidr_block = var.subnet_front_cidr_block
  availability_zone = var.az_front
  tags = {
    Name = "subnet_front"
  }
}

resource "aws_subnet" "subnet_back" {
  vpc_id     = aws_vpc.studi_vpc.id
  cidr_block = var.subnet_back_cidr_block
  availability_zone = var.az_back
  tags = {
    Name = "subnet_back"
  }
}

resource "aws_route_table_association" "subnet_front_association" {
  subnet_id      = aws_subnet.subnet_front.id
  route_table_id = aws_route_table.studi_rt.id
}

resource "aws_route_table_association" "subnet_back_association" {
  subnet_id      = aws_subnet.subnet_back.id
  route_table_id = aws_route_table.studi_rt.id
}


resource "aws_security_group" "sgr_emr_master" {
  name        = "sgr_emr_master"
  description = "Security group for EMR Master"
  vpc_id      = aws_vpc.studi_vpc.id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      description = "Allow TCP ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "emr_master"
  }
}

resource "aws_security_group" "sgr_emr_slave" {
  name        = "sgr_emr_slave"
  description = "Security group for EMR Slave"
  vpc_id      = aws_vpc.studi_vpc.id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      description = "Allow TCP ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "emr_master"
  }
}

resource "aws_emr_cluster" "spark_cluster" {
  name          = var.cluster_name
  release_label = var.release_label 
  applications  = var.applications

  ec2_attributes {
    subnet_id                         = aws_subnet.subnet_back.id
    instance_profile                  = var.instance_profile
    emr_managed_master_security_group = aws_security_group.sgr_emr_master.id
    emr_managed_slave_security_group  = aws_security_group.sgr_emr_slave.id
    key_name = var.key_name
  }

  service_role = var.service_role
  autoscaling_role = var.autoscaling_role

  master_instance_group {
    instance_type  = var.master_instance_type
    instance_count = var.master_instance_count
  }

  core_instance_group {
    instance_type  = var.core_instance_type
    instance_count = var.core_instance_count
  }
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = var.cluster_identifier
  engine                  = "docdb"
  engine_version          = var.engine_version
  master_username         = var.master_username
  master_password         = var.master_password
  enabled_cloudwatch_logs_exports = ["audit", "profiler"]
}

resource "aws_docdb_cluster_instance" "docdb_instances" {
  count              = var.instance_count
  identifier         = "${var.cluster_identifier}-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = var.instance_class
  engine             = "docdb"
}