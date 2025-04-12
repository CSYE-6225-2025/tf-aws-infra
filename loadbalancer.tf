# Security Group for Load Balancer
resource "aws_security_group" "load_balancer_sg" {
  name_prefix = "${var.vpc_name}-lb-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-lb-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "webapp_alb" {
  name               = "${var.vpc_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "${var.vpc_name}-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "webapp_tg" {
  name     = "${var.vpc_name}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/healthz"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }
}

data "aws_acm_certificate" "cert" {
  domain      = "${var.environment}.hardishah.me"
  statuses    = ["ISSUED"]
  most_recent = true
}

resource "aws_lb_listener" "webapp_listener" {
  load_balancer_arn = aws_lb.webapp_alb.arn
  port              = 443
  protocol          = "HTTPS"

  # Specify the SSL certificate ARN here
  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg.arn
  }
}
 