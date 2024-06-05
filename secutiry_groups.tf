

resource "aws_security_group" "sg_alb" {
  name        = var.sg_alb_name
  description = "incoming https traffic from cloudflare and ecs for health check"
  vpc_id      = aws_vpc.vpc.id
  # HTTPS access from only cloudflare
  ingress {

    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = concat(var.cloudflare_cidr_blocks_lb, [var.vpc_cidr])
  }
  # outbound internet access
  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ensure the VPC has an Internet gateway or this step will fail
  depends_on = [aws_internet_gateway.igw]
  tags       = merge(local.tags, { Name = "${var.env_name}-sg-alb" })
}


resource "aws_security_group" "sg_ecs" {
  name        = var.sg_ecs_name
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.vpc.id # Replace with your VPC ID
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
    description     = "Only ALB Traffic allowed"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_internet_gateway.igw]
  tags       = merge(local.tags, { Name = "${var.env_name}-sg-ecs" })
}

resource "aws_security_group" "sg_rds" {
  name        = "rds-sg" #TOBE
  description = "incoming db traffic from vpc to database"
  vpc_id      = aws_vpc.vpc.id
  # HTTPS access from only cloudflare
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = concat(var.cloudflare_cidr_blocks, [var.vpc_cidr]) #TOBE remove cloudflare once testing is done
  }
  # TOBE
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.tags, { Name = "${var.env_name}-sg-rds" })
}

resource "aws_security_group" "sg_jumphost" {
  name        = "jumphost-sg" #TOBE
  description = "incoming ssh traffic from cloudflare"
  vpc_id      = aws_vpc.vpc.id
  # HTTPS access from only cloudflare
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cloudflare_cidr_blocks
  }
  # TOBE
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "jumphost-sg"
    Environment = var.env_name
  }
}
