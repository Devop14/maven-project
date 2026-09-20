variable "name" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_ids" {
  type = list(string)
}
variable "master_password" {
  type      = string
  sensitive = true
}
variable "instance_class" {
  type    = string
  default = "db.t4g.medium"
}
variable "database_name" {
  type    = string
  default = "investment"
}
variable "tags" {
  type    = map(string)
  default = {}
}
