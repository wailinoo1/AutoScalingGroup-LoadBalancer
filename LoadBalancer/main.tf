resource "aws_s3_bucket" "asg-nginx-alb-logs" {
  bucket = var.asg-alblogs3
  tags = {
    Name        = "${var.asg-alblogs3}"
  }
}

resource "aws_s3_bucket_policy" "alb_access_logs_policy" {
  bucket = aws_s3_bucket.asg-nginx-alb-logs.bucket

  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::114774131450:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.asg-alblogs3}/*"
    }
  ]
})
}

resource "aws_lb" "terraform-alb" {
  name               = var.alb-name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg-id]
  subnets            = [for subnet in var.public-subnetid : subnet]
 

  enable_deletion_protection = false

     access_logs {
      bucket  = aws_s3_bucket.asg-nginx-alb-logs.id
      enabled = true
    }

  tags = {
    Environment = "${var.alb-name}"
  }
}


resource "aws_lb_listener" "listen443" {
  load_balancer_arn = aws_lb.terraform-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate

  default_action {
    type             = "forward"
    target_group_arn = var.asg-tg-arn
  }
  depends_on = [ aws_lb.terraform-alb]
}


resource "aws_lb_listener" "listen80" {
  load_balancer_arn = aws_lb.terraform-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {  
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  depends_on = [ aws_lb.terraform-alb ]
}

