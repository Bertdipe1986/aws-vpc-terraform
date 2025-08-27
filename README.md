This repository contains **Terraform Infrastructure as Code (IaC)** to provision a secure and scalable AWS VPC environment with compute resources.

## 🏗️ Infrastructure Provisioned
- **VPC** with public & private subnets  
- **Internet Gateway (IGW)** for external access  
- **NAT Gateway** for secure outbound traffic from private subnet  
- **Route Tables** for controlled traffic flow  
- **Security Groups & NACLs** for restricted access  
- **EC2 Instances** in public and private subnets (Ubuntu)  

## 📂 Project Structure
```
aws-vpc-terraform/
├── main.tf          # Main Terraform configuration
├── variables.tf     # Input variables
├── outputs.tf       # Output values (EC2 IPs, IDs, etc.)
├── provider.tf      # AWS provider configuration
├── README.md        # Project documentation
└── .gitignore       # Ignore Terraform state & secrets
```

## ⚡ Usage
```bash
# Initialize Terraform
terraform init

# Review execution plan
terraform plan

# Apply changes
terraform apply -auto-approve

# Destroy resources
terraform destroy -auto-approve
```

## 📤 Outputs
After applying, Terraform will return:
- **Public EC2 Public IP** (bastion / SSH access)  
- **Private EC2 Private IP** (internal use only)  
- **Instance IDs**  

## 🔐 Notes
- Never commit AWS credentials or `.pem` files.  
- `.gitignore` ensures sensitive files (`*.tfstate`, `.terraform/`, etc.) are ignored.  

## 🎯 Learning Objectives
This project demonstrates:
- Terraform IaC fundamentals  
- AWS networking best practices  
- Secure deployment of public & private compute resources  

## 👨‍💻 Author
**Oluwasijibomi Albert Ogundipe**  
Cloud & DevOps Engineer | AWS | Terraform | Kubernetes  
