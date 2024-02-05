# Building AWS Auto Scaling Group with Application Load Balancer using Terraform for more Scalable and Reliable Solution

<h2>Project Overview</h2>
<p>This project represents an orchestrated deployment of a scalable and resilient cloud infrastructure on AWS using Terraform, a popular infrastructure as code (IaC) tool. The architecture revolves around three key modules: Network, Autoscaling, and Loadbalancer, each contributing to the establishment of a robust environment capable of handling varying workloads while ensuring high availability and fault tolerance.</p>

![CHEESE](images/asgdia.jpg)

<h2>Description</h2>
<p>The project aimed to deploy a resilient , scalable and reliable AWS architecture using Terraform Infrastructure As Code (IaC) principles to streamline resource provisioning and management. Leveraging Terraform, the infrastructure was divided into three modular components: Network, Server, and Load Balancer.</p>

<h2>Pre-requisites</h2>
<p><b>S3 Bucket:</b> You need to have a S3 Bucket to store Terraform State Files</p>
<p><b>Certificate:</b> You need to request a certificate in AWS Certificate Manager to associate with Application Load Balancer</p>

<h2>Module Structure</h2>

![CHEESE](images/structure.jpg)

<h2>Network Module</h2>
<p>The Network module was responsible for creating the foundational components of the architecture within the VPC. This included defining the VPC itself, along with the associated subnets, route tables, and Internet Gateway. Two public subnets were designated for the ALB and one for NAT Gateway, while two private subnets were established across different availability zones to host the Auto Scaling Group with Desired 2 EC2 Instances.</p>

<p>In these modules , I've used Terraform Function <b>cidrsubnet</b> to create 4 subnets.This function will generate subnetes with "10.200.0.0/24", "10.200.1.0/24", "10.200.2.0/24", "10.200.3.0/24".</p>
<p>You can play subnet ranges as you wish for least subnet ranges</p>

```terraform
locals {
  subnet = cidrsubnets(var.vpc_cidr_block,8,8,8,8)
}
```
