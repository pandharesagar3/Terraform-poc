# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = var.vpc_name
    Environment = var.env_name
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.tags, {
  Name = "${var.env_name}-igw" })
}
data "aws_availability_zones" "available" {
  state = "available"
}
# Create Subnets
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.prv_subnet_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name        = var.prv_subnet_a_name
    Environment = var.env_name
  }
}
resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.prv_subnet_b_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name        = var.prv_subnet_b_name
    Environment = var.env_name
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.pub_subnet_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name        = var.pub_subnet_a_name
    Environment = var.env_name
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.pub_subnet_b_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name        = var.pub_subnet_b_name
    Environment = var.env_name
  }
}
# Create Nat Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name        = "nat-eip"
    Environment = var.env_name
  }
}
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id
  tags = {
    Name        = var.natgateway_name
    Environment = var.env_name
  }
}

# Create Route Tables
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name        = var.pub_route_table_name
    Environment = var.env_name
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = var.prv_route_table_name
    Environment = var.env_name
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  depends_on = [aws_nat_gateway.nat_gateway]
}

# Associate Subnets with Route Tables
resource "aws_route_table_association" "public_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "sg_vpc_endpoints" {
  name        = "vpc-endpoint-sg"
  description = "Security group for VPC endpoint"

  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing inbound traffic from any source
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # All protocols
    cidr_blocks = ["0.0.0.0/0"] # Allowing outbound traffic to any destination
  }

  tags = {
    Name        = "CloudWatch Logs Endpoint SG"
    Environment = var.env_name
  }
}
# Create VPC Endpoints
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region_name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_route_table.id]
  tags = {
    Name        = "S3 VPC Endpoint"
    Environment = var.env_name
  }
}

resource "aws_vpc_endpoint" "cloudwatch_logs_endpoint" {
  vpc_id             = aws_vpc.vpc.id
  service_name       = "com.amazonaws.${var.region_name}.logs"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.sg_vpc_endpoints.id]
  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id
  ]
  private_dns_enabled = true
  tags = {
    Name        = "Cloudwatch VPC Endpoint"
    Environment = var.env_name
  }
}

resource "aws_vpc_endpoint" "sns_endpoint" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region_name}.sns"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id
  ]
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.sg_vpc_endpoints.id]
  tags = {
    Name        = "SNS VPC Endpoint"
    Environment = var.env_name
  }
}

resource "aws_vpc_endpoint" "secrets_manager_endpoint" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region_name}.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id
  ]
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.sg_vpc_endpoints.id]
  tags = {
    Name        = "SecretManager VPC Endpoint"
    Environment = var.env_name
  }
}

# Create SNS Topic
resource "aws_sns_topic" "sns_topic" {
  name = var.log_topic_name
  tags = {
    Environment = var.env_name
  }

}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = var.sns_sub_email

}


resource "aws_iam_policy" "combined_policy" {
  name        = "combined_policy"
  description = "Combined policy for S3, Secret Manager, CloudWatch Logs, and SNS access"
  policy      = templatefile("${path.module}/task_role_policy.json", {})
  tags = {
    Environment = var.env_name
  }
}

resource "aws_iam_role" "task_role" {
  name = var.ecs_task_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = {
    Environment = var.env_name
  }
}

resource "aws_iam_role" "execution_role" {
  name = var.ecs_excuter_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = {
    Environment = var.env_name
  }
}

resource "aws_iam_role_policy_attachment" "combined_policy_attachment_task" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.combined_policy.arn
}

resource "aws_iam_role_policy_attachment" "combined_policy_attachment_execution" {
  role       = aws_iam_role.execution_role.name
  policy_arn = aws_iam_policy.combined_policy.arn
}

output "task_role_arn" {
  value = aws_iam_role.task_role.arn
}

output "execution_role_arn" {
  value = aws_iam_role.execution_role.arn
}

output "SNS_TOPIC_ARN" {
  value = "${aws_sns_topic.sns_topic.name} : ${aws_sns_topic.sns_topic.arn}"
}
