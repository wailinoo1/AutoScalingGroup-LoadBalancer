# Building AWS Auto Scaling Group with Application Load Balancer using Terraform for more Scalable and Reliable Solution

<h2>Project Overview</h2>
<p>This project represents an orchestrated deployment of a scalable and resilient cloud infrastructure on AWS using Terraform, a popular infrastructure as code (IaC) tool. The architecture revolves around three key modules: Network, Autoscaling, and Loadbalancer, each contributing to the establishment of a robust environment capable of handling varying workloads while ensuring high availability and fault tolerance.</p>

![CHEESE](images/asgdia.jpg)

<h2>Description</h2>
<p>The project aimed to deploy a resilient , scalable and reliable AWS architecture using Terraform Infrastructure As Code (IaC) principles to streamline resource provisioning and management. Leveraging Terraform, the infrastructure was divided into three modular components: Network, Server, and Load Balancer.</p>

<h2>Pre-requisites</h2>
<p><b>S3 Bucket:</b> You need to have a S3 Bucket to store Terraform State Files</p>
<p><b>Certificate:</b> You need to request a certificate in AWS Certificate Manager to associate with Application Load Balancer</p>
