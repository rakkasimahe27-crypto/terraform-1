# PRIMARY DATABASE
provider "aws" {
  region = "us-west-2"
}
resource "aws_db_instance" "dev" {
  identifier            = "dev-primary-db" # Added identifier to reference easily
  allocated_storage     = 20
  storage_type          = "gp2"
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t3.micro"
  max_allocated_storage = 100
  db_subnet_group_name  = aws_db_subnet_group.dev.name
  vpc_security_group_ids = [aws_security_group.dev.id]
  multi_az              = true

  username              = "admin"
  password              = "password123"
  parameter_group_name  = "default.mysql8.0"
  skip_final_snapshot   = true
  
  # REQUIRED: Automated backups must be enabled (> 0) to create a read replica
  backup_retention_period = 7 
}

# READ REPLICA
resource "aws_db_instance" "dev_replica" {
  identifier             = "dev-read-replica"
  
  # This tells Terraform this is a replica of the database above
  replicate_source_db    = aws_db_instance.dev.identifier 
  
  instance_class         = "db.t3.micro"
  vpc_security_group_ids = [aws_security_group.dev.id]
  skip_final_snapshot    = true

  # Note: A replica inherits storage, engine, and credentials from the source.
  # Do not declare password, username, or allocated_storage here.
}

# NETWORKING & SECURITY
resource "aws_db_subnet_group" "dev" {
  name       = "dev-subnet-group"
  subnet_ids = [aws_subnet.dev1.id, aws_subnet.dev2.id]

  tags = {
    Name = "dev-subnet-group"
  }
}

resource "aws_subnet" "dev1" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_subnet" "dev2" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
}

resource "aws_internet_gateway" "dev" {
  vpc_id = aws_vpc.dev.id
}
resource "aws_route_table" "dev" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev.id
  }
}
resource "aws_route_table_association" "dev1" {
  subnet_id      = aws_subnet.dev1.id
  route_table_id = aws_route_table.dev.id
}
resource "aws_route_table_association" "dev2" {
  subnet_id      = aws_subnet.dev2.id
  route_table_id = aws_route_table.dev.id
}
resource "aws_vpc" "dev" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dev-vpc"
  }
}

resource "aws_security_group" "dev" {
  name        = "dev-security-group"
  description = "Allow MySQL traffic"
  vpc_id      = aws_vpc.dev.id

  ingress {
    from_port   = 3306
    to_port     = 3306
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
# REDIS SECURITY GROUP
resource "aws_security_group" "redis_dev" {
  name        = "dev-redis-security-group"
  description = "Allow Redis traffic within VPC"
  vpc_id      = aws_vpc.dev.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    # Security Best Practice: Restrict Redis access strictly to the VPC CIDR
    cidr_blocks = [aws_vpc.dev.cidr_block] 
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# REDIS SUBNET GROUP
resource "aws_elasticache_subnet_group" "dev" {
  name       = "dev-redis-subnet-group"
  # Reusing your existing dev1 (us-west-2a) and dev2 (us-west-2b) subnets
  subnet_ids = [aws_subnet.dev1.id, aws_subnet.dev2.id]
}

# REDIS REPLICATION GROUP (MULTI-AZ)
resource "aws_elasticache_replication_group" "dev" {
  replication_group_id       = "dev-redis-cluster"
  description                = "Dev Redis Replication Group"
  engine                     = "redis"
  engine_version             = "7.1"
  node_type                  = "cache.t3.micro"
  port                       = 6379
  
  # Multi-AZ Configuration (1 Primary, 1 Replica)
  num_cache_clusters         = 2
  multi_az_enabled           = true
  automatic_failover_enabled = true
  
  subnet_group_name          = aws_elasticache_subnet_group.dev.name
  security_group_ids         = [aws_security_group.redis_dev.id]
  parameter_group_name       = "default.redis7"
  
  # Applies changes immediately rather than waiting for maintenance window
  apply_immediately          = true
}