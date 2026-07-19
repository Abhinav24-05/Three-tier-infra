resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnets
}

resource "aws_security_group" "alb_sg" {
  name   = "${var.name}-alb-sg"
  vpc_id = var.vpc_id

  ingress { from_port = 80; to_port = 80; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"] }
  egress  { from_port = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"] }
}

resource "aws_lb_target_group" "this" {
  name     = "${var.name}-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check { path = "/health"; interval = 30 }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

output "alb_arn" { value = aws_lb.this.arn }
output "target_group_arn" { value = aws_lb_target_group.this.arn }
output "alb_security_group_id" { value = aws_security_group.alb_sg.id }
output "alb_dns_name" { value = aws_lb.this.dns_name }
