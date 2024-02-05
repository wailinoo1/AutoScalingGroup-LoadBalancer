resource "aws_security_group" "wlo-terraform-lt-sg" {
  name   = "wlo-terraform-alb-sg"
  vpc_id = var.vpcid
  
  dynamic "ingress" {
    for_each = var.lt-ingress-port
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  }
  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
  }
}


resource "aws_launch_template" "template" {
  name_prefix = var.template-name

  block_device_mappings {
    device_name = "${var.device_name}"

    ebs {
      volume_size = var.volume_size
    }
  }


  image_id = var.image_id

  instance_type = var.instance_type

  key_name = var.keypair

  vpc_security_group_ids = [aws_security_group.wlo-terraform-lt-sg.id]

  user_data = filebase64("${path.module}/install-nginx.sh")
}


resource "aws_autoscaling_group" "asg" {
  name = var.asg_name
  vpc_zone_identifier  = [for subnet in var.subnetid : subnet]
  desired_capacity     = var.desire_number
  max_size             = var.max_number
  min_size             = var.min_number

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
}

resource "aws_lb_target_group" "asg-tgb" {
  name        = var.asg_tgb_name
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpcid
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asg-tgb" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = aws_lb_target_group.asg-tgb.arn

  depends_on = [ aws_autoscaling_group.asg , aws_lb_target_group.asg-tgb ]
}


resource "aws_autoscaling_policy" "example" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  name                   = "autoscalingTarget"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70
  }
  
}

resource "aws_sns_topic" "asg-alarmtopic" {
  name = var.sns-topicname
}

resource "aws_sns_topic_subscription" "email-sub" {
  topic_arn = aws_sns_topic.asg-alarmtopic.arn
  protocol  = "email"
  endpoint  = var.subcription_email
  depends_on = [ aws_sns_topic.asg-alarmtopic ]
}

resource "aws_cloudwatch_metric_alarm" "bat" {
  alarm_name          = var.alarm_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "EC2 in AutoScalingGroup ${var.asg_name} is high in CPU Utilization"
  alarm_actions     = [aws_sns_topic.asg-alarmtopic.arn]

  depends_on = [ aws_sns_topic.asg-alarmtopic , aws_sns_topic_subscription.email-sub]
}

