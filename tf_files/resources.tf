resource "aws_ecr_repository" "hello" {
  name                 = "hello_repo"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecs_cluster" "hello_cluster" {
  name = "hello_cluster"
}

resource "aws_ecs_service" "hello_service" {
  name = "hello_service"
  cluster                = aws_ecs_cluster.hello_cluster.arn
  launch_type            = "FARGATE"
  enable_execute_command = true

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 1
  task_definition                    = aws_ecs_task_definition.hello_td.arn

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.hello_sg.id]
    subnets          = ["****", "***", "***"]
  }
}

resource "aws_ecs_task_definition" "hello_td" {
  container_definitions = jsonencode([
    {
      name         = "hello_app"
      image        = "************.dkr.ecr.us-east-1.amazonaws.com/hello_repo"
      cpu          = 256
      memory       = 512
      essential    = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    }
  ])
  family                   = "hello_app"
  requires_compatibilities = ["FARGATE"]

  cpu                = "256"
  memory             = "512"
  network_mode       = "awsvpc"
  task_role_arn      = "arn:aws:iam::************:role/ecsTaskExecutionRole"
  execution_role_arn = "arn:aws:iam::************:role/ecsTaskExecutionRole"
}

resource "aws_security_group" "hello_sg" {
  name   = "hello_sg"
  vpc_id = "********"

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "custom"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}