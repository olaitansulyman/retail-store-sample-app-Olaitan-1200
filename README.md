# Project Bedrock — AWS EKS Microservices Deployment Lab

A hands-on cloud/DevOps portfolio project exploring infrastructure as code and deployment of a sample retail microservices application on AWS. This repository documents a learning implementation; it should not be interpreted as evidence of a live production service or production operations experience.

## Architecture

- **Infrastructure:** Terraform
- **Networking:** VPC with public/private subnets and security groups
- **Container orchestration:** Amazon EKS
- **Data services:** Amazon RDS (MySQL and PostgreSQL)
- **Event processing:** Amazon S3 and AWS Lambda
- **Ingress:** AWS Load Balancer Controller and Application Load Balancer
- **Deployment:** Kubernetes manifests managed with Kustomize
- **Automation:** GitHub Actions

See [ARCHITECTURE.md](./ARCHITECTURE.md) for the design notes and [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for deployment instructions.

## Repository layout

```text
.
├── .github/workflows/       # Terraform workflow
├── terraform/               # Root Terraform configuration and modules
├── kustomize/base/           # Kubernetes resources
├── ARCHITECTURE.md           # Architecture notes
├── DEPLOYMENT_GUIDE.md       # Deployment guide
├── deploy.sh                 # Deployment helper
└── README.md
```

## Prerequisites

- AWS CLI configured with an appropriately scoped IAM identity
- Terraform >= 1.0
- kubectl
- Kustomize (or kubectl with Kustomize support)
- An AWS account with the required service permissions

## Deployment outline

1. Review the Terraform configuration, variables, and estimated AWS costs.
2. Configure credentials using an AWS-supported mechanism such as an IAM role, IAM Identity Center, or short-lived environment credentials. Do not commit credentials.
3. Initialize and review the Terraform plan:

   ```bash
   cd terraform
   terraform init
   terraform validate
   terraform plan
   ```

4. Apply only after reviewing the plan and confirming the resources and costs:

   ```bash
   terraform apply
   ```

5. Configure kubectl for the cluster:

   ```bash
   aws eks update-kubeconfig --name project-bedrock-cluster --region us-east-1
   ```

6. Create the application namespace and required Kubernetes secrets using secure values supplied at deployment time. Do not place real credentials in manifests, shell history, source control, or README examples.
7. Deploy and verify the application:

   ```bash
   kubectl apply -k kustomize/base/
   kubectl get pods -n retail-app
   kubectl get ingress -n retail-app
   ```

## Database credentials and Kubernetes secrets

The following is a **placeholder-only** example. Replace values locally with credentials obtained from a secure secret store. For a real deployment, prefer AWS Secrets Manager or another managed secret store with an approved synchronization mechanism; avoid passing production passwords as literal command-line arguments.

```bash
kubectl create secret generic catalog-db \
  --from-literal=endpoint="$MYSQL_ENDPOINT" \
  --from-literal=username="$MYSQL_USERNAME" \
  --from-literal=password="$MYSQL_PASSWORD" \
  -n retail-app
```

Use a separate secret for each database and grant workloads only the access they require. Never commit populated secret manifests, Terraform state containing secret values, kubeconfig files, or credential exports.

## CI/CD

The repository includes a GitHub Actions workflow under `.github/workflows/`. Review its permissions, triggers, and deployment behavior before enabling it. Configure any required cloud access through GitHub Actions secrets or, preferably, GitHub OIDC with a narrowly scoped AWS IAM role. Do not add long-lived AWS access keys to workflow files.

## Cleanup

Remove Kubernetes resources and destroy lab infrastructure when finished to avoid ongoing AWS charges:

```bash
kubectl delete -k kustomize/base/
cd terraform
terraform destroy
```

Review the destroy plan before confirming. Some resources may incur charges while running, including EKS, load balancers, NAT gateways, and databases.

## Security notes

- Do not commit real passwords, access keys, private keys, kubeconfig files, or populated Terraform state.
- Treat Terraform state as sensitive even when the state file appears to contain only infrastructure metadata.
- Use least-privilege IAM policies and short-lived credentials.
- Use GitHub OIDC for AWS workflow authentication where supported.
- Rotate any credential that may have been exposed in a public repository.

## Project scope

This repository is a portfolio/lab exercise. The architecture and manifests describe the intended implementation; verify the current code, successful deployment evidence, and cloud resources before treating any component as operational.
