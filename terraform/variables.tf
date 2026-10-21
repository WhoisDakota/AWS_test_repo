variable "region" {
  type    = string
  default = "us-west-2"
}

variable "project" {
  type    = string
  default = "url-shortener"
}

variable "db_name" {
  type    = string
  default = "shortener"
}

variable "db_app_user" {
  type    = string
  default = "app_user"
}
