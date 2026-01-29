# Terraform AWS Junior Cloud Engineer Project


---

## Architecture

```
Internet
   |
Application Load Balancer (Public Subnets)
   |
Auto Scaling Group (EC2 - Private Subnets)
   |
RDS MySQL (Private Subnets)

Terraform Remote State:
S3 + DynamoDB (state locking)

Secrets Management:
AWS Secrets Manager
```

### Key Design Principles

* No EC2 instances are publicly accessible
* Database is fully isolated in private subnets
* Single public entry point via ALB
* Infrastructure is modular and environment-based

---

## AWS Services Used

* **VPC** – Custom networking with public & private subnets
* **Internet Gateway & NAT Gateway** – Controlled internet access
* **Application Load Balancer (ALB)** – Public entry point and traffic distribution
* **Auto Scaling Group (ASG)** – High availability and self-healing EC2 instances
* **EC2 (Amazon Linux 2)** – Application compute layer
* **RDS (MySQL)** – Managed relational database
* **IAM Roles** – Secure access without hardcoded credentials
* **AWS Secrets Manager** – Secure database credentials
* **S3 + DynamoDB** – Terraform remote state & locking

---

## Terraform Structure

```
terraform-aws-junior-cloud/
├── modules/
│   ├── vpc/
│   ├── alb/
│   ├── ec2/
│   └── rds/
├── envs/
│   ├── dev/
│   └── prod/
├── bootstrap/
│   └── remote-state/
└── README.md
```

### Why This Structure?

* **Modules** allow reusability and consistency
* **Environment folders** isolate dev and prod safely
* **Bootstrap folder** separates one-time infrastructure (remote state)

---

## Security Considerations

* EC2 instances run in **private subnets only**
* Security Groups use **SG-to-SG rules** instead of open CIDRs
* RDS is **not publicly accessible**
* IAM roles are used instead of access keys
* Secrets are stored in **AWS Secrets Manager**, not in code or Git
* Terraform state is encrypted and locked

---

## Terraform State Management

* Remote backend using **S3**
* State locking using **DynamoDB**
* Prevents concurrent state corruption
* Enables safe team collaboration

---

## How to Deploy (Dev Environment)

```bash
cd envs/dev
terraform init
terraform apply
```

After deployment:

* Access the application via the ALB DNS name
* EC2 instances are automatically registered to the ALB

---

## What This Project Demonstrates

* Real-world AWS infrastructure design
* Infrastructure as Code best practices
* Security-first cloud architecture

---

## Author

**Romany Ibrahim**
Aspiring Junior Cloud Engineer

---

> This project is intentionally designed to reflect real production patterns rather than simple tutorials.
