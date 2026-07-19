resource "aws_ecs_cluster" "this" {
  name = var.name
}

resource "aws_iam_role" "task_execution" {
  name = "${var.name}-task-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement { actions = ["sts:AssumeRole"] principals { type = "Service" identifiers = ["ecs-tasks.amazonaws.com"] } }
}

resource "aws_iam_role_policy_attachment" "exec_attach" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.task_execution.arn
  container_definitions = jsonencode([
    {
      name = "app"
      image = var.app_image
      essential = true
      portMappings = [{ containerPort = 8080, protocol = "tcp" }]
      environment = [ { name = "DD_AGENT_HOST", value = "127.0.0.1" }, { name = "DD_TRACE_AGENT_PORT", value = "8126" } ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.name}-app"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "app"
        }
      }
    },
    {
      name = "datadog-agent"
      image = "gcr.io/datadoghq/agent:latest"
      essential = false
      portMappings = [{ containerPort = 8126, protocol = "tcp" }]
      environment = [ { name = "DD_API_KEY", value = var.datadog_api_key }, { name = "DD_APM_ENABLED", value = "true" }, { name = "DD_LOGS_ENABLED", value = "false" } ]
    }
  ])
}

resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = "/ecs/${var.name}-app"
  retention_in_days = 14
}

resource "aws_ecs_service" "this" {
  name            = "${var.name}-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = var.private_subnet_ids
    security_groups = [aws_security_group.this.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name   = "app"
    container_port   = 8080
  }

  
}

resource "aws_security_group" "this" {
  name   = "${var.name}-sg"
  vpc_id = var.vpc_id

  ingress { from_port = 8080; to_port = 8080; protocol = "tcp"; security_groups = [var.alb_security_group_id] }
  ingress { from_port = 8126; to_port = 8126; protocol = "tcp"; cidr_blocks = ["10.0.0.0/8"] }
  egress  { from_port = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"] }
}

output "cluster_name" { value = aws_ecs_cluster.this.name }
output "service_arn" { value = aws_ecs_service.this.arn }
