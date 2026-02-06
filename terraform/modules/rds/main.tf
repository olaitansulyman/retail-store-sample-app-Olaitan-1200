resource "aws_db_subnet_group" "main" {
  name       = "project-bedrock-db-subnet"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "project-bedrock-db-subnet"
  }
}

resource "aws_security_group" "rds" {
  name        = "project-bedrock-rds-sg"
  description = "RDS security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project-bedrock-rds-sg"
  }
}

resource "aws_db_instance" "mysql" {
  identifier             = "bedrock-catalog-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "catalog"
  username               = "admin"
  password               = "BedrockPass123!"
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name = "bedrock-catalog-mysql"
  }
}

resource "aws_db_instance" "postgres" {
  identifier             = "bedrock-orders-postgres"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "orders"
  username               = "admin"
  password               = "BedrockPass123!"
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name = "bedrock-orders-postgres"
  }
}
