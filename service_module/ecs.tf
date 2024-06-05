
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/ecs/${var.env_name}/${var.ecs_task_name}"
  tags = var.tags
}

data "template_file" "task_def_template" {
  template = file("${path.module}/task-defination.tpl.json")

  vars = {
    task_name          = var.ecs_task_name
    region_name        = var.region_name
    image_url          = var.ecs_image_service_url
    secret_name        = var.secret_name
    awslogs_group_name = aws_cloudwatch_log_group.ecs_log_group.name
  }
}

resource "aws_ecs_task_definition" "task_def" {
  family                   = var.ecs_task_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
  container_definitions    = data.template_file.task_def_template.rendered

  tags = var.tags
}

resource "aws_ecs_service" "admin" {
  name                              = var.ecs_task_name
  cluster                           = var.cluster_id
  task_definition                   = aws_ecs_task_definition.task_def.arn
  enable_execute_command            = true
  launch_type                       = "FARGATE"
  desired_count                     = var.desired_count
  health_check_grace_period_seconds = 180

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_https.arn
    container_name   = var.ecs_task_name
    container_port   = 443

  }
  network_configuration {
    subnets         = var.subnets_ecs
    security_groups = var.sg_ecs_id
  }
  tags       = var.tags
  depends_on = [aws_lb_target_group.target_group_https]
}
