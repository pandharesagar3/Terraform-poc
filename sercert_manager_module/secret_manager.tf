locals {
  common_vars = {
    "ERROR_LOG_TOPIC_REGION" : var.region_name,
    "ENV_SECRET" : var.secret_name

  }
  final_json = merge(var.json_data_content, local.common_vars)
}
resource "aws_secretsmanager_secret" "secret_service" {
  name                    = var.secret_name
  tags                    = var.tags
  recovery_window_in_days = 0 #TOBE replace with 7 because once you delete it will not be recoverable

}

resource "aws_secretsmanager_secret_version" "sm_version" {
  secret_id     = aws_secretsmanager_secret.secret_service.id
  secret_string = jsonencode(local.final_json)
}
