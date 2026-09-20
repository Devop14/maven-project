variable "name" {
  type = string
}
variable "ui_bucket_domain_name" {
  type = string
}
variable "origin_access_control_id" {
  type = string
}
variable "api_origin_domain_name" {
  type = string
}
variable "web_acl_arn" {
  type    = string
  default = null
}
variable "tags" {
  type    = map(string)
  default = {}
}
