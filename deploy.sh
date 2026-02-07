#!/bin/bash
set -e

echo "=== Project Bedrock Deployment Script ==="

# Step 1: Create Terraform backend
echo "Step 1: Creating Terraform backend..."
aws s3api create-bucket \
  --bucket bedrock-terraform-state-alt-soe-025-1200 \
  --region us-east-1 2>/dev/null || echo "Bucket already exists"

aws s3api put-bucket-versioning \
  --bucket bedrock-terraform-state-alt-soe-025-1200 \
  --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name bedrock-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1 2>/dev/null || echo "DynamoDB table already exists"

# Step 2: Deploy infrastructure
echo "Step 2: Deploying infrastructure with Terraform..."
cd terraform
terraform init
terraform apply -auto-approve

# Step 3: Configure kubectl
echo "Step 3: Configuring kubectl..."
aws eks update-kubeconfig --name project-bedrock-cluster --region us-east-1

# Step 4: Wait for cluster to be ready
echo "Step 4: Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Step 5: Create database secrets
echo "Step 5: Creating database secrets..."
MYSQL_ENDPOINT=$(terraform output -raw rds_mysql_endpoint)
POSTGRES_ENDPOINT=$(terraform output -raw rds_postgres_endpoint)

kubectl create namespace retail-app --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic catalog-db \
  --from-literal=endpoint=$MYSQL_ENDPOINT \
  --from-literal=username=dbadmin \
  --from-literal=password=BedrockPass123! \
  -n retail-app --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic orders-db \
  --from-literal=endpoint=$POSTGRES_ENDPOINT \
  --from-literal=username=dbadmin \
  --from-literal=password=BedrockPass123! \
  -n retail-app --dry-run=client -o yaml | kubectl apply -f -

# Step 6: Deploy application
echo "Step 6: Deploying application..."
cd ..
kubectl apply -k kustomize/base/

# Step 7: Wait for pods
echo "Step 7: Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pods --all -n retail-app --timeout=300s

# Step 8: Get application URL
echo "Step 8: Getting application URL..."
sleep 30
ALB_URL=$(kubectl get ingress retail-store-ingress -n retail-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Step 9: Generate grading file
echo "Step 9: Generating grading.json..."
cd terraform
terraform output -json > ../grading.json

echo ""
echo "=== Deployment Complete ==="
echo "Application URL: http://$ALB_URL"
echo "Grading file: grading.json"
echo ""
echo "Developer Credentials:"
terraform output developer_access_key_id
terraform output developer_secret_access_key
