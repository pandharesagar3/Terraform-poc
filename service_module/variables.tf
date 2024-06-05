variable "env_name" {
  description = "The name of the environment"
  type        = string
}
variable "ecs_task_name" {
  description = "The name of the ECS task it will service or admin or django"
  type        = string
}
variable "subnets_ecs" {
  description = "The subnets to deploy ECS Task"
  type        = list(string)

}
variable "subnets_alb" {
  description = "The subnets to deploy the ALB to"
  type        = list(string)
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}
variable "certificate_arn" {
  description = "The ARN of the certificate to use for HTTPS"
  type        = string
}
variable "cluster_id" {
  description = "The ID of the ECS cluster"
  type        = string
}
variable "region_name" {
  description = "The name of the region"
  type        = string
}
variable "ecs_image_service_url" {
  description = "The URL of the ECS image"
  type        = string
}
variable "secret_name" {
  description = "The name of the Secrets Manager secret"
  type        = string
}

variable "task_role_arn" {
  description = "The ARN of the ECS task role"
  type        = string
}
variable "execution_role_arn" {
  description = "The ARN of the ECS execution role"
  type        = string
}
variable "sg_ecs_id" {
  description = "The ID of the ECS security group"
  type        = list(string)

}
variable "sg_alb_id" {
  description = "The ID of the ALB security group"
  type        = list(string)

}
variable "desired_count" {
  description = "The desired number of tasks"
  type        = number
  default     = 0

}

variable "cpu" {
  description = "The number of CPU units to reserve for the container"
  type        = string
  default     = "4096"

}
variable "memory" {
  description = "The amount of memory (in MiB) to allow the container to use"
  type        = string
  default     = "8192"
}
