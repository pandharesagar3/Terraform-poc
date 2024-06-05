variable "secret_name" {
  type = string
}
variable "region_name" {
  type = string
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "env_name" {
  type = string
}
variable "ecs_task_name" {
  type = string
}
variable "ecs_image_service_url" {
  type = string
}
variable "cluster_id" {
  type = string
}
variable "sg_ecs_id" {
  type = list(string)
}
variable "subnets_ecs" {
  type = list(string)
}
variable "task_role_arn" {
  type = string
}
variable "execution_role_arn" {
  type = string
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
variable "desired_count" {
  description = "The desired number of tasks"
  type        = number
  default     = 0

}
