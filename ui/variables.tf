variable "REACT_APP_ADMIN_ONLY" {
  type = string
}
variable "app_name" {
  type = string
}
variable "ui_branch_name" {
  type = string
}
variable "domain_name" {
  type = string
}

variable "tags" {
  type = map(string)

}
variable "git_access_token" {
  type      = string
  sensitive = true
}

variable "json_data_content" {
  type = map(any)
}
