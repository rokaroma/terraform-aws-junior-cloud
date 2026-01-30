resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "RDS security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ec2_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-rds-sg"
  }
}


resource "aws_db_subnet_group" "this" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.environment}-db-subnet-group"
  }
}

resource "aws_secretsmanager_secret" "db" {
  name = "${var.environment}/rds/credentials"
}

resource "aws_db_instance" "this" {
  identifier              = "${var.environment}-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "appdb"
  username                = jsondecode(
    aws_secretsmanager_secret_version.db.secret_string
  )["username"]
  password                = jsondecode(
    aws_secretsmanager_secret_version.db.secret_string
  )["password"]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.this.name

  tags = {
    Name = "${var.environment}-rds"
  }
}



resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = jsondecode(
    aws_secretsmanager_secret_version.db.secret_string
  )["username"]
    password = jsondecode(
    aws_secretsmanager_secret_version.db.secret_string
  )["password"]
  })
}



