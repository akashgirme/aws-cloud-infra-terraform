resource "aws_lb" "load_balancer" {
  name               = "${var.environment}-load-balancer"
  internal           = false # Set Load-Balancer Internet facing
  load_balancer_type = "application"
  security_groups    = [var.security_group.id]
  subnets            = flatten([for subnet in var.public_subnets : subnet.id])

  # access_logs {
  #   bucket = var.lb_connection_logs_bucket.id
  #   enabled = true
  # }

  enable_deletion_protection = true
  # Make deletion protection true in production.
  enable_tls_version_and_cipher_suite_headers = true

  # Request will bypass Web Application Firewall if it fails and continue request to target
  enable_waf_fail_open = true

  tags = {
    Environment = "${var.environment}-load-balancer"
  }

  # depends_on = [var.lb_connection_logs_bucket]
}



resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    # On SSL remove target_group_arn from here.
    # target_group_arn = aws_lb_target_group.lb_target_group.arn

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.ssl_certificiate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}


resource "aws_lb_target_group" "lb_target_group" {
  name = "${var.environment}-lb-target-group"

  # Port on which target receives traffic
  port                          = 80
  protocol                      = "HTTP"
  vpc_id                        = var.vpc.id
  slow_start                    = 0 # Seconds Amount time for targets to warm up before the load balancer sends them a full share of requests.
  load_balancing_algorithm_type = "round_robin"

  # Only support on HTTPS listner
  preserve_client_ip = true

  health_check {
    path = "/api" # This is path where load balancer hit api to check response if response is in status code 200-299,
    # then it pass the health check
    # In Actual production set path to /api or whatever is actual path

    interval            = 5
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 3
    matcher             = "200-299"
  }

  deregistration_delay = 5 # Specifies the amount of time for the load balancer to wait before deregistering a target after it is considered unhealthy.
}


