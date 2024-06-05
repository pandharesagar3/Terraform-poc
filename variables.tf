variable "region_name" {
  description = "The AWS region name"
  type        = string
}
variable "profile_name" {
  description = "aws cli profile name"
  type        = string
}

variable "env_name" {
  description = "The environment name"
  type        = string
}

variable "vpc_name" {
  description = "The VPC name"
  type        = string
}

variable "vpc_cidr" {
  description = "The VPC CIDR block"
  type        = string
}

variable "prv_route_table_name" {
  description = "private route table"
  type        = string
}
variable "pub_route_table_name" {
  description = "public route table"
  type        = string
}

variable "natgateway_name" {
  description = "The NAT gateway name"
  type        = string
}

variable "prv_subnet_a_name" {
  description = "The private subnet A name"
  type        = string
}

variable "prv_subnet_b_name" {
  description = "The private subnet B name"
  type        = string
}

variable "pub_subnet_a_name" {
  description = "The public subnet A name"
  type        = string
}

variable "pub_subnet_b_name" {
  description = "The public subnet B name"
  type        = string
}

variable "prv_subnet_a_cidr" {
  description = "The private subnet A CIDR block"
  type        = string
}

variable "prv_subnet_b_cidr" {
  description = "The private subnet B CIDR block"
  type        = string
}

variable "pub_subnet_a_cidr" {
  description = "The public subnet A CIDR block"
  type        = string
}

variable "pub_subnet_b_cidr" {
  description = "The public subnet B CIDR block"
  type        = string
}

variable "log_topic_name" {
  description = "The log topic name"
  type        = string
}

variable "ecs_cluster_name" {
  description = "The ECS cluster name"
  type        = string
}

variable "sm_service_name" {
  description = "The Secrets Manager service secret name"
  type        = string
}

variable "sm_admin_name" {
  description = "The Secrets Manager admin secret name"
  type        = string
}

variable "sm_django_name" {
  description = "The Secrets Manager Django secret name"
  type        = string
}

variable "sm_importer_name" {
  description = "The Secrets Manager importer secret name"
  type        = string
}
variable "ecs_task_role_name" {
  description = "The name of the ECS task role"
  type        = string
}

variable "ecs_excuter_role_name" {
  description = "The name of the ECS executor role"
  type        = string
}

variable "ecs_image_service_url" {
  description = "The URL of the ECS service image"
  type        = string
}

variable "ecs_image_importer_url" {
  description = "The URL of the ECS importer image"
  type        = string
}
variable "ecs_task_service_name" {
  description = "The ECS task service name"
  type        = string
}

variable "ecs_task_admin_name" {
  description = "The ECS task admin name"
  type        = string
}

variable "ecs_task_django_name" {
  description = "The ECS task Django name"
  type        = string
}

variable "ecs_task_importer_name" {
  description = "The ECS task importer name"
  type        = string
}

variable "alb_name" {
  description = "The Application Load Balancer name"
  type        = string
}

variable "alb_tg_service_name" {
  description = "The ALB target group service name"
  type        = string
}

variable "alb_tg_admin_name" {
  description = "The ALB target group admin name"
  type        = string
}

variable "alb_tg_django_name" {
  description = "The ALB target group Django name"
  type        = string
}

variable "sg_alb_name" {
  description = "The security group for ALB name"
  type        = string
}

variable "sg_ecs_name" {
  description = "The security group for ECS name"
  type        = string
}
variable "certificate_arn" {
  description = "SSL certificate arn"
  type        = string
}
variable "sns_sub_email" {
  description = "Email group for error logs notificaiton subscription"
  type        = string
}
variable "ui_branch_name" {
  type = string

}
variable "cloudflare_cidr_blocks" {
  type = list(string)
}
variable "cloudflare_cidr_blocks_lb" {
  type = list(string)

}
variable "DBA_ADMIN_USER" {
  type      = string
  sensitive = false
}
variable "DBA_ADMIN_PASSWORD" {
  type = string
  # sensitive = true
}
variable "DB_USER" {
  type = string
}
variable "DB_NAME" {
  type = string

}
variable "DB_PASSWORD" {
  type = string
  # sensitive = true
}
variable "ENCRYPTION_KEY" {
  type = string

}
variable "DJANGO_SUPERUSER_PASSWORD" {
  type = string
  # sensitive = true

}
variable "DJANGO_SUPERUSER_EMAIL" {
  type = string

}
variable "git_access_token" {
  type      = string
  sensitive = true
}
