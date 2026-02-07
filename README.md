# Project Bedrock - Production-Grade Microservices on AWS EKS

## Overview
This project deploys a production-grade retail store application on AWS EKS with RDS databases, S3/Lambda event processing, and ALB ingress.

## Prerequisites
- AWS CLI configured
- Terraform >= 1.0
- kubectl
- Git

## Project Structure
```
project-bedrock/
├── terraform/           # Infrastructure as Code
│   ├── modules/
│   │   ├── vpc/        # VPC with public/private subnets
│   │   ├── eks/        # EKS cluster and node groups
│   │   ├── rds/        # MySQL and PostgreSQL databases
│   │   ├── s3-lambda/  # S3 bucket and Lambda processor
│   │   └── iam/        # Developer IAM user and RBAC
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── kustomize/          # Kubernetes manifests
│   └── base/
└── .github/workflows/  # CI/CD pipeline
```

## Deployment Steps

### 1. Create Terraform Backend (One-time setup)
```bash
cd terraform
aws s3api create-bucket \
  --bucket bedrock-terraform-state-alt-soe-025-1200 \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket bedrock-terraform-state-alt-soe-025-1200 \
  --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name bedrock-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### 2. Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### 3. Configure kubectl
```bash
aws eks update-kubeconfig --name project-bedrock-cluster --region us-east-1
```

### 4. Create Database Secrets
```bash
# Get RDS endpoints from Terraform outputs
MYSQL_ENDPOINT=$(terraform output -raw rds_mysql_endpoint)
POSTGRES_ENDPOINT=$(terraform output -raw rds_postgres_endpoint)

# Create secrets
kubectl create secret generic catalog-db \
  --from-literal=endpoint=$MYSQL_ENDPOINT \
  --from-literal=username=dbadmin \
  --from-literal=password=BedrockPass123! \
  -n retail-app

kubectl create secret generic orders-db \
  --from-literal=endpoint=$POSTGRES_ENDPOINT \
  --from-literal=username=dbadmin \
  --from-literal=password=BedrockPass123! \
  -n retail-app
```

### 5. Deploy Application
```bash
kubectl apply -k kustomize/base/
```

### 6. Verify Deployment
```bash
kubectl get pods -n retail-app
kubectl get ingress -n retail-app
```

### 7. Get Application URL
```bash
kubectl get ingress retail-store-ingress -n retail-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

### 8. Test Lambda Function
```bash
BUCKET_NAME=$(terraform output -raw assets_bucket_name)
echo "test" > test.txt
aws s3 cp test.txt s3://$BUCKET_NAME/
aws logs tail /aws/lambda/bedrock-asset-processor --follow
```

### 9. Generate Grading File
```bash
terraform output -json > grading.json
```

## Developer Access Credentials
After deployment, retrieve the developer credentials:
```bash
terraform output developer_access_key_id
terraform output developer_secret_access_key
```

## CI/CD Pipeline
The GitHub Actions pipeline automatically:
- Runs `terraform plan` on pull requests
- Runs `terraform apply` on merge to main
- Generates `grading.json` after successful deployment

### Setup GitHub Secrets
Add these secrets to your GitHub repository:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Resource Naming (Critical for Grading)
- EKS Cluster: `project-bedrock-cluster`
- VPC Name Tag: `project-bedrock-vpc`
- Namespace: `retail-app`
- IAM User: `bedrock-dev-view`
- S3 Bucket: `bedrock-assets-alt-soe-025-1200`
- Lambda: `bedrock-asset-processor`
- All resources tagged with `Project: Bedrock`

## Cleanup
```bash
kubectl delete -k kustomize/base/
terraform destroy
```

## Troubleshooting

### Pods not starting
```bash
kubectl describe pod <pod-name> -n retail-app
kubectl logs <pod-name> -n retail-app
```

### RDS connection issues
Check security groups allow traffic from EKS nodes to RDS.

### ALB not created
Verify AWS Load Balancer Controller is installed and running.
