
resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_cluster_name
  tags = local.tags
}
#                   service |admin  |django
# DJANGO_ADMIN      |False  |False  |True
# ENABLE_ADMIN_APIS |False  |True   |False
# ENABLE_CRON_JOBS  |False  |True   |False
# ENABLE_SF_APIS    |False  |True   |False

locals {
  sm_file_name = [
    { secret_name = var.sm_service_name, file_name = "_vcheck_service",
      extra_vars = { DJANGO_SUPERUSER_PASSWORD = var.DJANGO_SUPERUSER_PASSWORD
    DJANGO_SUPERUSER_EMAIL = var.DJANGO_SUPERUSER_EMAIL } },
    { secret_name = var.sm_admin_name, file_name = "_admin_service",
      extra_vars = { DJANGO_SUPERUSER_PASSWORD = var.DJANGO_SUPERUSER_PASSWORD
    DJANGO_SUPERUSER_EMAIL = var.DJANGO_SUPERUSER_EMAIL } },
    { secret_name = var.sm_django_name, file_name = "_django",
      extra_vars = { DJANGO_SUPERUSER_PASSWORD = var.DJANGO_SUPERUSER_PASSWORD
    DJANGO_SUPERUSER_EMAIL = var.DJANGO_SUPERUSER_EMAIL } },
    { secret_name = var.sm_importer_name, file_name = "_importer", extra_vars = {} }
  ]
  _common_dynamic_vars = {
    ERROR_LOG_TOPIC_ARN  = aws_sns_topic.sns_topic.arn
    ERROR_LOG_TOPIC_NAME = aws_sns_topic.sns_topic.name
    DB_USER              = var.DB_USER
    DB_NAME              = var.DB_NAME
    DB_HOST              = aws_db_instance.postgres_instance.address
    DB_PASSWORD          = var.DB_PASSWORD
    ENCRYPTION_KEY       = var.ENCRYPTION_KEY
  }
}

module "secret_manager" {
  source            = "./sercert_manager_module"
  count             = length(local.sm_file_name)
  secret_name       = local.sm_file_name[count.index].secret_name
  env_name          = var.env_name
  region_name       = var.region_name
  json_data_content = merge(jsondecode(file("${path.module}/sm_config_files/${local.sm_file_name[count.index].file_name}.json")), local._common_dynamic_vars, local.sm_file_name[count.index].extra_vars)
}

locals {
  ecs_services_loop = [
    {
      secret_name   = var.sm_admin_name
      ecs_task_name = var.ecs_task_admin_name
      desired_count = 0
    },
    {
      secret_name   = var.sm_service_name
      ecs_task_name = var.ecs_task_service_name
      desired_count = 0
    },
    {
      secret_name   = var.sm_django_name
      ecs_task_name = var.ecs_task_django_name
      desired_count = 0
    }
  ]
}
module "ecs_tasks" {
  count                 = length(local.ecs_services_loop)
  source                = "./service_module"
  env_name              = var.env_name
  secret_name           = local.ecs_services_loop[count.index].secret_name
  ecs_task_name         = local.ecs_services_loop[count.index].ecs_task_name
  cluster_id            = aws_ecs_cluster.cluster.id
  region_name           = var.region_name
  ecs_image_service_url = var.ecs_image_service_url
  task_role_arn         = aws_iam_role.task_role.arn
  execution_role_arn    = aws_iam_role.execution_role.arn
  sg_ecs_id             = [aws_security_group.sg_ecs.id]
  sg_alb_id             = [aws_security_group.sg_alb.id]
  vpc_id                = aws_vpc.vpc.id
  subnets_alb           = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  subnets_ecs           = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
  tags                  = local.tags
  certificate_arn       = var.certificate_arn
  desired_count         = local.ecs_services_loop[count.index].desired_count
  cpu                   = "4096"
  memory                = "8192"
  # depends_on            = count.index == 0 ? [] : [module.ecs_tasks[count.index - 1].id]
  # depends_on = count.index == 0 ? [aws_iam_role.execution_role.arn] : concat([aws_iam_role.execution_role.arn], slice(module.ecs_tasks[*].id, 0, count.index))
}

module "importer" {
  source                = "./importer"
  env_name              = var.env_name
  secret_name           = var.sm_importer_name ###
  ecs_task_name         = var.ecs_task_importer_name
  region_name           = var.region_name
  cluster_id            = aws_ecs_cluster.cluster.id
  ecs_image_service_url = var.ecs_image_importer_url
  task_role_arn         = aws_iam_role.task_role.arn
  execution_role_arn    = aws_iam_role.execution_role.arn
  sg_ecs_id             = [aws_security_group.sg_ecs.id]
  subnets_ecs           = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
  cpu                   = "4096"
  memory                = "8192"
  desired_count         = 0
  tags                  = local.tags
}

output "admin_alb_dns" {
  value = length(module.ecs_tasks) > 0 ? "CNAME    ${var.env_name}-admin-api   ${module.ecs_tasks[0].alb_dns}" : "No ECS tasks available"
}

output "service_alb_dns" {
  value = length(module.ecs_tasks) > 1 ? "CNAME    ${var.env_name}-api   ${module.ecs_tasks[1].alb_dns}" : "No ECS tasks available"
}

output "django_alb_dns" {
  value = length(module.ecs_tasks) > 2 ? "CNAME    ${var.env_name}-django-api   ${module.ecs_tasks[2].alb_dns}" : "No ECS tasks available"
}
