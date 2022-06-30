variable "aws_id" {}
variable "aws_access_key_id" {}
variable "aws_secret_access_key_id" {}
variable "aws_region" {}
variable "app_name" {}
variable "domain" {}
variable "domain_host_api_name" {}
variable "domain_host_web_name" {}
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "db_database" {}
variable "master_key" {}

locals {
  fqdn = {
    api_name = "${var.domain_host_api_name}.${var.domain}",
    web_name = "${var.domain_host_web_name}.${var.domain}"
  }
  bucket = {
    name = local.fqdn.web_name
  }
}


variable "availability_zones" {
  type    = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "cidr_block" {
  default = "10.0.0.0/21"
}

variable "azs" {
  type    = list(string)
  default = ["1a", "1c"]
}
