# Nuon App Config: Coder on EKS

---

This configuration deploys Coder on an EKS cluster using Nuon. It provisions:
- A minimal EKS cluster (2x t3.medium nodes)
- Bitnami Postgres for Coder
- Coder via Helm chart
- ALB for external access
- Certificate via cert-manager

## Components
- `coder-db.toml`: Bitnami Postgres Helm chart
- `coder.toml`: Coder Helm chart
- `alb.toml`: Application Load Balancer for Coder
- `certificate.toml`: TLS certificate

## Actions
- `create_db_secret.toml`: Creates the Coder DB URL secret in the cluster

## How it works
1. EKS cluster is created with a small node group
2. Postgres is installed in the `coder` namespace
3. A secret with the DB URL is created
4. Coder is installed and configured to use the DB
5. ALB exposes Coder externally

---

This config is minimal and cost-effective for development/testing.
