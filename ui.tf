locals {
  ui_params = [
    # {
    #   admin_flage = "true"
    #   file_name   = "_ui_admin_portal"
    # },
    {
      admin_flage = "false"
      file_name   = "_ui_portal"
    }
  ]
}

module "web_ui" {
  count                = length(local.ui_params)
  REACT_APP_ADMIN_ONLY = local.ui_params[count.index].admin_flage
  json_data_content    = jsondecode(file("${path.module}/sm_config_files/${local.ui_params[count.index].file_name}.json"))
  source               = "./ui"
  domain_name          = "vcheckglobal.net" #DONOT CHANGE
  app_name             = var.env_name
  ui_branch_name       = var.ui_branch_name
  git_access_token     = var.git_access_token
  tags                 = local.tags
}

