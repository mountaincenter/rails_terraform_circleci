resource "aws_cloudwatch_log_group" "ecs_log" {
  name = "/ecs/example/${local.name}"
}
module "ecs_task_execution_role" {
  source     = "../iam_role"
  name       = "ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy_arn = data.aws_iam_policy.ecs_task_execution_role_policy.arn
}

resource "aws_ecs_task_definition" "main" {
  family                   = local.name
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.container_definitions.rendered
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
}

resource "aws_lb_target_group" "main" {
  name        = "${local.name}-tg"
  vpc_id      = var.vpc_id
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  health_check {
    port = 80
    path = "/"
  }
}

resource "aws_lb_listener_rule" "http_rule" {
  listener_arn = var.http_listener_arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.id
  }
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

resource "aws_lb_listener_rule" "https_rule" {
  listener_arn = var.https_listener_arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.id
  }
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

resource "aws_security_group" "ecs" {
  name        = "${local.name}-sg"
  description = "security group of nginx ecs"
  vpc_id      = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = local.name
  }
}

resource "aws_security_group_rule" "http_ingress" {
  security_group_id = aws_security_group.ecs.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https_ingress" {
  security_group_id = aws_security_group.ecs.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_ecs_service" "main" {
  name            = "${local.name}-service"
  launch_type     = "FARGATE"
  desired_count   = "1"
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.main.arn
  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = var.public_subnet_ids
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "nginx"
    container_port   = 80
  }

}