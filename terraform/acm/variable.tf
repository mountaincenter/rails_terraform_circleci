variable "domain" {}
variable "domain_host_api_name" {}
variable "domain_host_web_name" {}
locals {
  fqdn = {
    api_name = "${var.domain_host_api_name}.${var.domain}",
    web_name = "${var.domain_host_web_name}.${var.domain}"
  }
  bucket = {
    name = local.fqdn.web_name
  }
}