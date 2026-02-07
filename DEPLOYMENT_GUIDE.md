# Project Bedrock - Deployment Guide

## 🏗️ Architecture Overview

### Infrastructure Components:
- **VPC**: Custom VPC with public and private subnets across multiple AZs
- **EKS Cluster**: `project-bedrock-cluster` running Kubernetes 1.28+
- **Data Layer**: 
  - RDS MySQL for orders database
  - RDS PostgreSQL for catalog database
- **Event Processing**: S3 bucket with Lambda function for event-driven processing
- **Monitoring**: CloudWatch logs for all services
- **Security**: IAM roles, RBAC, and security groups

### Application Architecture:
- **Microservices**: 6-tier retail application
  - UI (Frontend)
  - Catalog Service
  - Orders Service
  - Carts Service
  - Checkout Service
  - Assets Service

## 📋 Prerequisites

- AWS CLI configured
- kubectl installed
- Terraform installed
- Access to AWS account

## 🚀 Deployment Steps

### 1. Clone the Repository
```bash
git clone <your-repo-url>
cd project-bedrock
```

### 2. Deploy Infrastructure with Terraform
```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

This will create:
- VPC and networking
- EKS cluster
- RDS databases
- S3 bucket and Lambda function
- IAM roles and policies

### 3. Configure kubectl
```bash
aws eks update-kubeconfig --name project-bedrock-cluster --region us-west-2
```

### 4. Deploy Application
```bash
cd ../kustomize
kubectl apply -k base/
```

### 5. Verify Deployment
```bash
kubectl get pods -n retail-app
kubectl get svc -n retail-app
kubectl get ingress -n retail-app
```

## 🌐 Accessing the Application

### Option 1: Port Forward (Development)
```bash
kubectl port-forward -n retail-app svc/ui 8080:8080
```
Then access: http://localhost:8080

### Option 2: LoadBalancer (Production)
If LoadBalancer is configured, get the external URL:
```bash
kubectl get svc -n retail-app ui
```

### Option 3: Ingress
```bash
kubectl get ingress -n retail-app
```
Access via the ALB hostname shown in the ADDRESS column.

## 🔐 Grading Credentials

**IAM User**: `bedrock-dev-view`

**Access Key ID**: `<provided separately in CREDENTIALS.txt>`

**Secret Access Key**: `<provided separately in CREDENTIALS.txt>`

**Region**: `us-west-2`

### Permissions:
- EKS cluster read access
- RDS read access
- S3 read access
- CloudWatch logs read access
- VPC read access

## 📊 Verification Commands

### Check All Pods
```bash
kubectl get pods -n retail-app
```

Expected output: All pods in `Running` state

### Check Services
```bash
kubectl get svc -n retail-app
```

### Check Ingress
```bash
kubectl get ingress -n retail-app
```

### View Logs
```bash
kubectl logs -n retail-app -l app.kubernetes.io/name=ui
```

### Check RDS Databases
```bash
aws rds describe-db-instances --region us-west-2
```

### Check S3 Bucket
```bash
aws s3 ls | grep bedrock
```

### Check Lambda Function
```bash
aws lambda list-functions --region us-west-2 | grep bedrock
```

## 🧪 Testing the Application

### Test UI Service
```bash
kubectl port-forward -n retail-app svc/ui 8080:8080
curl http://localhost:8080
```

### Test Catalog Service
```bash
kubectl port-forward -n retail-app svc/catalog 8080:8080
curl http://localhost:8080/catalogue
```

### Test Orders Service
```bash
kubectl port-forward -n retail-app svc/orders 8080:8080
curl http://localhost:8080/orders
```

## 📁 Repository Structure

```
project-bedrock/
├── terraform/              # Infrastructure as Code
│   ├── main.tf
│   ├── vpc.tf
│   ├── eks.tf
│   ├── rds.tf
│   ├── s3-lambda.tf
│   └── outputs.tf
├── kustomize/             # Kubernetes manifests
│   └── base/
│       ├── kustomization.yaml
│       ├── namespace.yaml
│       ├── *-deployment.yaml
│       ├── *-service.yaml
│       └── ingress.yaml
├── lambda/                # Lambda function code
│   └── event-processor.py
├── grading.json          # Grading file
└── DEPLOYMENT_GUIDE.md   # This file
```

## 🔧 Troubleshooting

### Pods not starting
```bash
kubectl describe pod <pod-name> -n retail-app
kubectl logs <pod-name> -n retail-app
```

### Database connection issues
Check RDS security groups and endpoint configuration

### Ingress not working
Verify AWS Load Balancer Controller is installed:
```bash
kubectl get deployment -n kube-system aws-load-balancer-controller
```

## 🧹 Cleanup

To destroy all resources:
```bash
kubectl delete -k kustomize/base/
cd terraform
terraform destroy -auto-approve
```

## 📞 Support

For issues or questions, refer to the grading.json file for infrastructure details.

## ✅ Submission Checklist

- [x] Infrastructure deployed via Terraform
- [x] EKS cluster running
- [x] All 6 microservices deployed and running
- [x] RDS databases created
- [x] S3 + Lambda event processing configured
- [x] CloudWatch logging enabled
- [x] IAM user with read-only access created
- [x] grading.json generated
- [x] Repository is public/accessible
- [x] Deployment guide provided
