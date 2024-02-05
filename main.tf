module "network" {
  source = "./Network"
  vpc_cidr_block   = "10.200.0.0/16"
  vpcname = "wlo-terraform-vpc"
  subnet-name = "terraform-subnet"
  wlo-terraform-igw-name = "wlo-terraform-igw"
  natgw-name = "terraform-nat-gw"
  publicrtname = "public-subnet-routetable"
  privatertname = "private-subnet-routetable"
}


module "autoscalinggroup"{
    source = "./AutoScaling"
    vpcid = module.network.vpcid
    instance_type = "t2.micro"
    keypair = "wlo-keypair"
    lt-ingress-port = [22,80,443]
    template-name = "wlo-terraform-lt"
    device_name = "/dev/sdf"
    volume_size = 50
    image_id = "ami-0e5d58de654dfb50d"
    asg_tgb_name = "wlo-asg-tg-terraform"
    subnetid = module.network.subnetid
    asg_name = "wlo-asg-terraform"
    alarm_name = "wlo-asg-cpu-alarm"
    sns-topicname = "asg-terraform-sns"
    subcription_email = "wailinoo2012@gmail.com"
    desire_number = 2
    min_number = 2
    max_number = 4
}

module "loadbalancer" {
  source = "./LoadBalancer"
  public-subnetid = module.network.public-subnetid
  vpcid = module.network.vpcid
  alb-name = "asg-nginx-alb-wlo"
  asg-alblogs3 = "asg-albnginxlogs-wlo"
  sg-id = module.autoscalinggroup.sg-id
  asg-tg-arn = module.autoscalinggroup.asg-tg-arn
  certificate = "arn:aws:acm:ap-southeast-1:896836667748:certificate/31e9d408-5919-4cc4-b69e-2c1129b177e2"
}