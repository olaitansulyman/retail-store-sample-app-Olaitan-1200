resource "aws_iam_user" "developer" {
  name = "bedrock-dev-view"

  tags = {
    Name = "bedrock-dev-view"
  }
}

resource "aws_iam_user_policy_attachment" "developer_readonly" {
  user       = aws_iam_user.developer.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_access_key" "developer" {
  user = aws_iam_user.developer.name
}

resource "aws_iam_policy" "eks_view" {
  name = "bedrock-eks-view-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "eks:DescribeCluster",
        "eks:ListClusters"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_user_policy_attachment" "developer_eks" {
  user       = aws_iam_user.developer.name
  policy_arn = aws_iam_policy.eks_view.arn
}

data "aws_eks_cluster" "main" {
  name = var.cluster_name
}

resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.cluster_name} --region us-east-1"
  }

  depends_on = [data.aws_eks_cluster.main]
}

resource "null_resource" "configure_rbac" {
  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply -f - <<EOF
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: aws-auth
        namespace: kube-system
      data:
        mapUsers: |
          - userarn: ${aws_iam_user.developer.arn}
            username: bedrock-dev-view
            groups:
              - view-only
      EOF

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
    EOT
  }

  depends_on = [null_resource.update_kubeconfig]
}
