provider "aws" {
  region = "var.aws_region"
}

locals {
  subnets = [
    "var.subnet_id_1",
    "var.subnet_id_2",
  ]
}

data "aws_ecs_cluster" "target" {
  cluster_name = "var.ecs_cluster_name"
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "var.task_family_name"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "var.task_cpu"
  memory                   = "var.task_memory"
  execution_role_arn       = "arn:aws:iam::account-id:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name      = "var.container_name",
      image     = "nginx:latest",
      essential = true,
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80,
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "nginx" {
  name            = "var.service_name"
  cluster         = data.aws_ecs_cluster.target.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = local.subnets
    security_groups = ["var.security_group_id"]
    assign_public_ip = false
  }

  deployment_controller {
    type = "ECS"
  }
}
