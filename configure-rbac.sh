#!/bin/bash
set -e

echo "Configuring RBAC for bedrock-dev-view user..."

# Get developer user ARN
DEV_USER_ARN=$(cd terraform && terraform output -raw developer_user_arn)

# Update kubeconfig
aws eks update-kubeconfig --name project-bedrock-cluster --region us-east-1

# Configure aws-auth ConfigMap
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapUsers: |
    - userarn: ${DEV_USER_ARN}
      username: bedrock-dev-view
      groups:
        - view-only
EOF

# Create ClusterRoleBinding
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: bedrock-dev-view-binding
subjects:
- kind: User
  name: bedrock-dev-view
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: view
  apiGroup: rbac.authorization.k8s.io
EOF

echo "RBAC configuration complete!"
