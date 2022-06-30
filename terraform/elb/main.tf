resource "aws_security_group" "alb" {
  name   = "${var.app_name}-alb"
  vpc_id = var.vpc_id
  dynamic "ingress" {
    for_each = var.ingress_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.app_name}-sg-alb"
  }
}

resource "aws_lb" "main" {
  name               = "${var.app_name}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_listener" "http" {
  port              = "80"
  protocol          = "HTTP"
  load_balancer_arn = aws_lb.main.arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "connected HTTP status_code:200 OK"
    }
  }
}

resource "aws_lb_listener" "https" {
  port              = "443"
  protocol          = "HTTPS"
  load_balancer_arn = aws_lb.main.arn
  certificate_arn   = var.acm_id
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "connected HTTPS status_code:200 OK"
    }
  }
}

resource "aws_route53_record" "api" {
  type    = "A"
  name    = local.fqdn.api_name
  zone_id = data.aws_route53_zone.api.id
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}