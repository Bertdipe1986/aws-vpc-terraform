# AWS VPC Terraform Setup — KCVPC

This repo contains Terraform IaC to provision:
- VPC with public & private subnets
- Internet Gateway and NAT Gateway
- Route tables for controlled traffic flow
- Security Groups and NACLs
- EC2 instances in public and private subnets

## Usage
```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Outputs
- Public EC2 Public IP
- Private EC2 Private IP
