output "sg-id"{
    value = aws_security_group.wlo-terraform-lt-sg.id
}

output "asg-tg-arn" {
  value = aws_lb_target_group.asg-tgb.arn
}