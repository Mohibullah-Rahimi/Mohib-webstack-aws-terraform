# modules/web/main.tf
# ALB + Target Group + Launch Template + AutoScaling Group

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_lb" "alb" {
  name               = "${var.project}-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.alb_sg_id]

  tags = {
    Name      = "${var.project}-alb"
    Project   = var.project
    CreatedBy = "Mohibullah-Rahimi"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.project}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Project   = var.project
    CreatedBy = "Mohibullah-Rahimi"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# Use a Launch Template so ASG can reference it
resource "aws_launch_template" "lt" {
  name_prefix   = "${var.project}-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name           # CHANGE_ME: ensure this key exists in your AWS account

  vpc_security_group_ids = [var.web_sg_id]

  user_data = base64encode(file("${path.module}/../../scripts/user_data.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name      = "${var.project}-web"
      Project   = var.project
      CreatedBy = "Mohibullah-Rahimi"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "${var.project}-asg"
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-web"
    propagate_at_launch = true
  }
}

# CloudWatch alarm example (ASG average CPU > 70%)
resource "aws_cloudwatch_metric_alarm" "high_cpu_asg" {
  alarm_name          = "${var.project}-asg-high-cpu"
  alarm_description   = "Alarm if ASG average CPU > 70%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}