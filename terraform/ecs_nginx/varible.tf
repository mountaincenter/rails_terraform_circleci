variable "app_name" {}
variable "vpc_id" {}
variable "http_listener_arn" {}
variable "https_listener_arn" {}
variable "cluster_name" {}
variable "public_subnet_ids" {}
locals {
  name = "${var.app_name}-nginx"
}