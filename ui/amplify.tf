locals {
  app_name = var.REACT_APP_ADMIN_ONLY == "true" ? "${var.app_name}-admin" : "${var.app_name}"
}
resource "aws_amplify_app" "portal" {

  name                     = local.app_name
  repository               = "https://github.com/vcheck-global/vcheck-web"
  platform                 = "WEB"
  description              = local.app_name
  access_token             = var.git_access_token
  enable_branch_auto_build = true

  build_spec = <<-EOT
version: 1
frontend:
  phases:
    preBuild:
      commands:
        # - rm yarn.lock
        - yarn install
    build:
      commands:
        - if [ "$REACT_APP_ADMIN_ONLY" = "true" ]; then yarn run buildAdmin; else yarn run build; fi
  artifacts:
    # IMPORTANT - Please verify your build output directory
    baseDirectory: build
    files:
      - '**/*'
  cache:
    paths:
      - node_modules/**/*
  EOT

  # The default rewrites and redirects added by the Amplify Console.
  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/"
  }

  custom_rule {
    source = "</^[^.]+$|\\.(?!(css|gif|ico|jpg|js|png|txt|svg|woff|woff2|ttf|map|json|webp)$)([^.]+$)/>"
    status = "200"
    target = "/index.html"
  }
  environment_variables = var.json_data_content
  tags                  = var.tags
}

resource "aws_amplify_branch" "branch_portal" {
  app_id            = aws_amplify_app.portal.id
  branch_name       = var.ui_branch_name
  framework         = "React"
  display_name      = var.ui_branch_name
  enable_auto_build = true
  stage             = "PRODUCTION"

}

# resource "aws_amplify_webhook" "branch_portal" {
#   app_id      = aws_amplify_app.portal.id
#   branch_name = aws_amplify_branch.branch_portal.branch_name
#   description = "trigger poc"
# }
# resource "aws_amplify_domain_association" "portal" {
#   app_id                 = aws_amplify_app.portal.id
#   domain_name            = var.domain_name # only top level domain
#   enable_auto_sub_domain = true
#   wait_for_verification  = false

#   sub_domain {
#     branch_name = aws_amplify_branch.branch_portal.branch_name
#     prefix      = ""
#   }

# }

