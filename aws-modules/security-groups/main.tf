resource "aws_security_group" "rds_security_group" {
  name   = "${var.environment}-postgres-rds"
  vpc_id = var.vpc.id

  ingress {
    from_port   = "5432"
    to_port     = "5432"
    protocol    = "tcp"
    cidr_blocks = [var.vpc.cidr_block]
  }

  egress {
    from_port   = "5432"
    to_port     = "5432"
    protocol    = "tcp"
    cidr_blocks = [var.vpc.cidr_block]
  }

  tags = {
    Name = "${var.environment}-postgres-rds"
  }
}

resource "aws_security_group" "redis_security_group" {
  name   = "${var.environment}-elasticache"
  vpc_id = var.vpc.id

  ingress {
    from_port   = "6379"
    to_port     = "6379"
    protocol    = "tcp"
    cidr_blocks = [var.vpc.cidr_block]
  }

  egress {
    from_port   = "6379"
    to_port     = "6379"
    protocol    = "tcp"
    cidr_blocks = [var.vpc.cidr_block]
  }

  tags = {
    Name = "${var.environment}-elasticache"
  }
}

resource "aws_security_group" "launch_template_security_group" {
  name   = "${var.environment}-lauch-template"
  vpc_id = var.vpc.id

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = [var.vpc.cidr_block]
  }

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = [var.vpc.cidr_block]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = [var.vpc.cidr_block]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-lauch-template"
  }
}


resource "aws_security_group" "load_balancer_security_group" {
  name   = "${var.environment}-load-balancer"
  vpc_id = var.vpc.id

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = [var.vpc.cidr_block]
  }

  egress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = [var.vpc.cidr_block]
  }

  tags = {
    Name = "${var.environment}-load-balancer"
  }
}



