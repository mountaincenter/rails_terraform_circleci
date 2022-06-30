resource "aws_ecs_cluster" "main" {
  name = var.app_name
}

resource "aws_cloudwatch_log_group" "ecs_log" {
  name              = "./ecs/example/${var.app_name}"
  retention_in_days = 180
}