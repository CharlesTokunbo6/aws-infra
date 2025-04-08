# AWS Infrastructure Terraform Project

This repository contains Terraform code for deploying a comprehensive AWS infrastructure that includes VPC, public and private subnets, NAT gateway, Internet Gateway, EC2 instances with auto-scaling, load balancer, and CloudWatch/CloudTrail monitoring with S3 storage.

## Architecture Overview


The infrastructure consists of the following components:

- **Networking**

  - VPC with public and private subnets across multiple availability zones
  - Internet Gateway for public internet access
  - NAT Gateway for private subnet outbound internet access
  - Route tables and security groups

- **Compute**

  - Auto Scaling Group with EC2 instances
  - Application Load Balancer
  - Launch template with user data script

- **Monitoring**

  - CloudWatch for metrics and logs
  - CloudTrail for API activity logging
  - Private S3 bucket for log storage
  - CloudWatch alarms for resource monitoring

- **State Management**
  - S3 bucket for Terraform state storage
  - DynamoDB table for state locking

## Prerequisites

- AWS CLI installed and configured
- Terraform (version 1.0.0 or later)
- An AWS account with appropriate permissions
- Git for version control

## Project Structure

```
.
├── main.tf                # Main configuration file that calls all modules
├── variables.tf           # Root module variables
├── outputs.tf             # Root module outputs
├── providers.tf           # Provider configuration
├── backend.tf             # Backend configuration for state storage
├── .github
│   └── workflows
│       └── terraform.yml  # GitHub Actions workflow for CI/CD
├── modules
│   ├── vpc                # Networking resources
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute            # EC2, ASG, and ALB resources
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── files
│   │       └── user_data.sh  # Bootstrap script for EC2 instances
│   ├── monitoring         # CloudWatch, CloudTrail, and logging resources
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── s3                 # S3 bucket for Terraform state
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── dynamodb           # DynamoDB for state locking
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── .gitignore
```

## Manual Deployment

### 1. Clone the Repository

```bash
git clone https://github.com/CharlesTokunbo6/aws-infra.git
cd aws-infra
```

### 2. Initialize Backend Resources

First, you need to create the S3 bucket and DynamoDB table for remote state storage:

```bash
# Comment out the backend configuration in backend.tf
# (or comment out the terraform section containing backend configuration)

# Initialize Terraform
terraform init

# Create only S3 and DynamoDB resources
terraform apply -target=module.s3_state -target=module.dynamodb_lock
```

### 3. Configure Remote Backend

After creating the S3 bucket and DynamoDB table, update the backend configuration with your bucket name:

```bash
# Uncomment the backend configuration in backend.tf and update the bucket name
# terraform {
#   backend "s3" {
#     bucket         = "your-unique-bucket-name"  # Update this
#     key            = "terraform.tfstate"
#     region         = "us-west-2"                # Update if needed
#     dynamodb_table = "terraform-state-lock"
#     encrypt        = true
#   }
# }

# Reinitialize Terraform with the remote backend
terraform init -reconfigure
```

### 4. Customize Variables

Update the variables to suit your environment:

```bash
# Create a terraform.tfvars file
cat > terraform.tfvars << EOF
aws_region          = "us-west-2"  # Change to your preferred region
environment         = "dev"
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones  = ["us-west-2a", "us-west-2b"]  # Match these to your region
instance_type       = "t2.micro"
logs_bucket_name    = "your-unique-logs-bucket-name"  # Must be globally unique
EOF
```

### 5. Deploy the Infrastructure

```bash
# View the execution plan
terraform plan

# Apply the changes
terraform apply
```

### 6. Verify the Deployment

Once deployed, you can verify the infrastructure:

```bash
# List outputs
terraform output

# Get the load balancer DNS name
terraform output alb_dns_name
```

Visit the load balancer DNS in your browser to see EC2 instance IP addresses as the ALB balances between instances.

### 7. Destroy the Infrastructure

When you're done, you can remove all resources:

```bash
# Destroy all resources
terraform destroy
```

## Deployment via GitHub Actions

### 1. Fork or Clone the Repository

Fork or clone this repository to your GitHub account.

### 2. Set up GitHub Repository Secrets

In your GitHub repository:

1. Go to Settings > Secrets and variables > Actions
2. Add the following repository secrets:

- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
- `TF_STATE_BUCKET`: Your S3 bucket name for Terraform state (optional, if initializing backend in CI/CD)
- `TF_LOCK_TABLE`: Your DynamoDB table name for state locking (optional, if initializing backend in CI/CD)

### 3. Update Workflow File (Optional)

If needed, update the `.github/workflows/terraform.yml` file to:

- Change the AWS region
- Adjust Terraform version
- Modify the branches that trigger deployments
- Update the backend configuration

### 4. Initial Backend Setup

Since GitHub Actions needs a backend for state management, you'll need to create the S3 bucket and DynamoDB table:

Option 1: Create manually in AWS console
Option 2: Deploy via AWS CLI
Option 3: Deploy locally first using the manual instructions above

### 5. Push Changes to Trigger Deployment

The workflow will run automatically when you push to the main/master branch or create a pull request.

```bash
git add .
git commit -m "Initial infrastructure setup"
git push origin main
```

### 6. Monitor the Workflow

1. Go to the "Actions" tab in your GitHub repository
2. Click on the running workflow to see its progress
3. Review logs for any errors

### 7. Workflow Behaviors

- **Pull Requests**: The workflow will run `terraform plan` and post the results as a comment
- **Pushes to main**: The workflow will run `terraform apply` to deploy the changes
- **Manual Trigger**: You can manually trigger the workflow from the Actions tab

## Customization

### EC2 Configuration

The EC2 instances are configured with a simple user data script that displays the instance's public IP address. To customize:

1. Modify `modules/compute/files/user_data.sh`
2. Update `modules/compute/main.tf` to change instance type, AMI, or other settings

### Monitoring Settings

CloudWatch and CloudTrail monitoring can be customized:

1. Set `enable_monitoring = false` in terraform.tfvars to disable CloudTrail
2. Modify `modules/monitoring/main.tf` to change log retention periods or alarm thresholds
3. Update the CloudWatch agent configuration in the user data script

### Networking Configuration

To customize the VPC and subnets:

1. Update CIDR blocks and availability zones in terraform.tfvars
2. Modify `modules/vpc/main.tf` for more advanced networking changes

## Troubleshooting

### Common Issues

1. **S3 Bucket Name Conflict**: S3 bucket names must be globally unique. If you get a "BucketAlreadyExists" error, choose a different bucket name.

2. **IAM Permissions**: Ensure your AWS credentials have sufficient permissions to create all resources.

3. **AWS Region Limits**: Some regions may have service limitations or require service quota increases.

4. **Terraform State Lock**: If a previous run crashed, you might need to manually release the state lock in DynamoDB.

### Debugging

1. Enable Terraform logging:

```bash
export TF_LOG=DEBUG
```

2. Check CloudWatch logs for EC2 instance issues:

```bash
aws logs get-log-events --log-group-name "/aws/ec2/dev" --log-stream-name "INSTANCE_ID"
```

## Security Considerations

- All S3 buckets have public access blocked
- CloudTrail logs are encrypted
- VPC uses proper network segmentation with public/private subnets
- EC2 instances in public subnets have security groups limiting access

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request
