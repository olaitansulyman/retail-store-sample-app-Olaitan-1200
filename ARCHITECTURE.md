# Project Bedrock - Architecture Diagram

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud (us-west-2)                       │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                         VPC (10.0.0.0/16)                          │ │
│  │                                                                    │ │
│  │  ┌──────────────────────┐      ┌──────────────────────┐          │ │
│  │  │  Public Subnet 1     │      │  Public Subnet 2     │          │ │
│  │  │  (10.0.1.0/24)       │      │  (10.0.2.0/24)       │          │ │
│  │  │                      │      │                      │          │ │
│  │  │  ┌────────────────┐  │      │  ┌────────────────┐  │          │ │
│  │  │  │  NAT Gateway   │  │      │  │  NAT Gateway   │  │          │ │
│  │  │  └────────────────┘  │      │  └────────────────┘  │          │ │
│  │  │  ┌────────────────┐  │      │  ┌────────────────┐  │          │ │
│  │  │  │ Internet GW    │  │      │  │  ALB/Ingress   │  │          │ │
│  │  │  └────────────────┘  │      │  └────────────────┘  │          │ │
│  │  └──────────────────────┘      └──────────────────────┘          │ │
│  │           │                              │                        │ │
│  │  ┌────────▼──────────────┐      ┌───────▼──────────────┐         │ │
│  │  │  Private Subnet 1     │      │  Private Subnet 2    │         │ │
│  │  │  (10.0.3.0/24)        │      │  (10.0.4.0/24)       │         │ │
│  │  │                       │      │                      │         │ │
│  │  │  ┌─────────────────┐  │      │  ┌─────────────────┐ │         │ │
│  │  │  │ EKS Worker Node │  │      │  │ EKS Worker Node │ │         │ │
│  │  │  │                 │  │      │  │                 │ │         │ │
│  │  │  │ ┌─────────────┐ │  │      │  │ ┌─────────────┐ │ │         │ │
│  │  │  │ │ UI Pod      │ │  │      │  │ │ Catalog Pod │ │ │         │ │
│  │  │  │ └─────────────┘ │  │      │  │ └─────────────┘ │ │         │ │
│  │  │  │ ┌─────────────┐ │  │      │  │ ┌─────────────┐ │ │         │ │
│  │  │  │ │ Orders Pod  │ │  │      │  │ │ Carts Pod   │ │ │         │ │
│  │  │  │ └─────────────┘ │  │      │  │ └─────────────┘ │ │         │ │
│  │  │  │ ┌─────────────┐ │  │      │  │ ┌─────────────┐ │ │         │ │
│  │  │  │ │Checkout Pod │ │  │      │  │ │ Assets Pod  │ │ │         │ │
│  │  │  │ └─────────────┘ │  │      │  │ └─────────────┘ │ │         │ │
│  │  │  └─────────────────┘  │      │  └─────────────────┘ │         │ │
│  │  └──────────────────────┘      └──────────────────────┘         │ │
│  │           │                              │                        │ │
│  │  ┌────────▼──────────────┐      ┌───────▼──────────────┐         │ │
│  │  │  Private Subnet 3     │      │  Private Subnet 4    │         │ │
│  │  │  (10.0.5.0/24)        │      │  (10.0.6.0/24)       │         │ │
│  │  │                       │      │                      │         │ │
│  │  │  ┌─────────────────┐  │      │  ┌─────────────────┐ │         │ │
│  │  │  │ RDS MySQL       │  │      │  │ RDS PostgreSQL  │ │         │ │
│  │  │  │ (Orders DB)     │  │      │  │ (Catalog DB)    │ │         │ │
│  │  │  └─────────────────┘  │      │  └─────────────────┘ │         │ │
│  │  └──────────────────────┘      └──────────────────────┘         │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                      Event Processing Layer                        │ │
│  │                                                                    │ │
│  │  ┌──────────────┐         ┌──────────────┐                        │ │
│  │  │  S3 Bucket   │────────▶│   Lambda     │                        │ │
│  │  │  (Events)    │ trigger │  Function    │                        │ │
│  │  └──────────────┘         └──────────────┘                        │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                      Monitoring & Logging                          │ │
│  │                                                                    │ │
│  │  ┌──────────────────────────────────────────────────────────────┐ │ │
│  │  │                    CloudWatch Logs                           │ │ │
│  │  │  - EKS Control Plane Logs                                    │ │ │
│  │  │  - Application Logs                                          │ │ │
│  │  │  - Lambda Logs                                               │ │ │
│  │  └──────────────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                      Security & Access                             │ │
│  │                                                                    │ │
│  │  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐        │ │
│  │  │ IAM Roles    │    │ Security     │    │ RBAC         │        │ │
│  │  │ & Policies   │    │ Groups       │    │ (K8s)        │        │ │
│  │  └──────────────┘    └──────────────┘    └──────────────┘        │ │
│  └────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Network Layer (VPC)
- **CIDR**: 10.0.0.0/16
- **Public Subnets**: 2 subnets for internet-facing resources
- **Private Subnets**: 4 subnets for EKS nodes and databases
- **Availability Zones**: Multi-AZ deployment for high availability
- **NAT Gateways**: For private subnet internet access
- **Internet Gateway**: For public subnet internet access

### 2. Compute Layer (EKS)
- **Cluster Name**: project-bedrock-cluster
- **Kubernetes Version**: 1.28+
- **Node Groups**: Auto-scaling worker nodes
- **Microservices**:
  - UI Service (Port 8080)
  - Catalog Service (Port 8080)
  - Orders Service (Port 8080)
  - Carts Service (Port 8080)
  - Checkout Service (Port 8080)
  - Assets Service (Port 8080)

### 3. Data Layer
- **RDS MySQL**: Orders database
  - Multi-AZ deployment
  - Automated backups
  - Encryption at rest
- **RDS PostgreSQL**: Catalog database
  - Multi-AZ deployment
  - Automated backups
  - Encryption at rest

### 4. Event Processing
- **S3 Bucket**: Event storage
- **Lambda Function**: Event processor
  - Triggered by S3 events
  - Processes and logs events
  - CloudWatch integration

### 5. Ingress & Load Balancing
- **Application Load Balancer**: Routes traffic to services
- **Ingress Controller**: Kubernetes ingress management
- **Service Type**: ClusterIP for internal services

### 6. Monitoring & Logging
- **CloudWatch Logs**: Centralized logging
  - EKS control plane logs
  - Application container logs
  - Lambda function logs
- **CloudWatch Metrics**: Performance monitoring

### 7. Security
- **IAM Roles**: Service-specific permissions
- **Security Groups**: Network-level security
- **RBAC**: Kubernetes role-based access control
- **Encryption**: Data at rest and in transit

## Traffic Flow

### User Request Flow:
```
Internet → ALB → Ingress → UI Service → Backend Services → Databases
```

### Event Processing Flow:
```
Application → S3 Bucket → Lambda Function → CloudWatch Logs
```

### Data Flow:
```
Orders Service ←→ RDS MySQL
Catalog Service ←→ RDS PostgreSQL
```

## High Availability

- **Multi-AZ Deployment**: Resources spread across multiple availability zones
- **Auto Scaling**: EKS nodes scale based on demand
- **Load Balancing**: Traffic distributed across healthy instances
- **Database Replication**: RDS Multi-AZ for failover

## Security Layers

1. **Network Security**: VPC, Security Groups, NACLs
2. **Application Security**: RBAC, IAM roles
3. **Data Security**: Encryption at rest and in transit
4. **Access Control**: IAM policies, K8s RBAC

## Scalability

- **Horizontal Pod Autoscaling**: Pods scale based on CPU/memory
- **Cluster Autoscaling**: Nodes added/removed based on demand
- **Database Scaling**: RDS can scale vertically
- **Stateless Services**: Easy to scale horizontally
