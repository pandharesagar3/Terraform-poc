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
  type    = string
  default = ""
}
variable "json_data_content" {
  type = map(any)
}
