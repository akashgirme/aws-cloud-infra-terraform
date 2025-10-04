# 🏗️ 2-Tier Web Application AWS Infrastructure with Terraform

This project provisions a **2-tier web application infrastructure** on **AWS** using **Terraform**.  
It automates deployment of a scalable and highly available environment consisting of an **application layer** (EC2 servers) and a **data layer** (RDS and ElastiCache).  

The infrastructure ensures performance, scalability, and fault tolerance using AWS managed services such as **Auto Scaling**, **Load Balancer**, **SNS Notifications**, and **CloudWatch Metrics**.

---

## 🧩 Architecture Overview

### **Core Components**
- **VPC**: Custom Virtual Private Cloud with public and private subnets.
- **Security Groups**: Configured to restrict inbound/outbound traffic.
- **EC2 Launch Template**: Defines reusable configuration for EC2 instances.
- **Auto Scaling Group (ASG)**: Dynamically adjusts the number of EC2 instances based on CPU utilization.
- **Elastic Load Balancer (ELB)**: Distributes incoming traffic across multiple EC2 instances.
- **RDS (Relational Database Service)**: Managed PostgreSQL instance as the primary data store.
- **ElastiCache (Redis)**: Caching layer to improve performance.
- **S3 Bucket**: Stores the remote Terraform state file for team collaboration and persistence.
- **SNS (Simple Notification Service)**: Sends notifications for auto scaling activities.
- **CloudWatch Metrics**: Triggers Auto Scaling actions when CPU utilization crosses defined thresholds (e.g., 50%).

---

## ⚙️ Prerequisites

Before running this infrastructure, ensure you have the following installed:

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- An **AWS account** with sufficient permissions (EC2, VPC, RDS, IAM, ELB, etc.)
- AWS credentials configured locally (`~/.aws/credentials`)

---

## 🔑 AWS Authentication Setup

You can configure your AWS credentials using the CLI:

```bash
aws configure
```

Provide the following when prompted:
AWS Access Key ID: <your-access-key>
AWS Secret Access Key: <your-secret-key>
Default region name: <your-region>
Default output format: json

----------------------

## 🪣 Creating the S3 Bucket for Terraform State

Terraform uses an S3 bucket to store its remote state file, which tracks your deployed infrastructure.

Before running terraform init, create the S3 bucket manually:
```bash
aws s3api create-bucket \
  --bucket terraform-state-file \
  --region <region> \
  --create-bucket-configuration LocationConstraint=<region>
```

Optionally, enable versioning to preserve state history:

```bash
aws s3api put-bucket-versioning \
  --bucket my-terraform-state-bucket \
  --versioning-configuration Status=Enabled
```

Then, confirm the bucket exists:

```bash
aws s3 ls
```

Ensure the same bucket name is configured in your Terraform main.tf file:
```HCL
terraform {
  backend "s3" {
    bucket         = "terraform-state-file"
    key            = "terraform"
    region         = "<region>"
    encrypt        = true
  }
}
```

## 🚀 Deploying the Infrastructure
```bash
# Initialize Terraform (downloads required providers and modules)
terraform init

# Review the execution plan
terraform plan

# Apply the configuration to create infrastructure
terraform apply
```

To destroy the entire infrastructure when no longer needed:

```bash
terraform destroy
```
