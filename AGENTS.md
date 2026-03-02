# Homelab Infrastructure - Agent Guidelines

## Overview
This repository uses GitOps with ArgoCD for infrastructure management. Terraform, Kubernetes (Talos), Helm charts, and Docker Compose are the primary tools. **No traditional build/lint/test commands** — deployment is via ArgoCD from the `main` branch.

---

## ⚠️ CRITICAL — Kubernetes GitOps Rules

### NEVER do any of the following directly:
- `helm install` / `helm upgrade --install` — FORBIDDEN for deployments
- `kubectl apply` to deploy or fix workloads
- `kubectl edit` / `kubectl patch` / `kubectl delete` on live objects
- Install operators, CRDs, or external dependencies without explicit approval

### GitOps Flow (ALWAYS follow):
1. Update Helm values → `./kubernetes/helm-charts/<app-name>/values.yaml`
2. Create/update ArgoCD Application → `./kubernetes/argocd/apps/<app-name>/`
3. Reuse existing projects (`infrastructure`, `media-stack`) or create new one in `./kubernetes/argocd/projects/`
4. Commit to feature branch: `opencode/<task>/<feature>`
5. Raise PR → wait for approval → merge to `main`
6. ArgoCD auto-syncs from `main` only

### ArgoCD Application Template:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: <app-name>
  namespace: argocd
spec:
  project: <existing-project>   # 'infrastructure' or 'media-stack'
  source:
    repoURL: <repo-url>
    targetRevision: main         # ALWAYS main
    path: kubernetes/helm-charts/<app-name>
  destination:
    server: https://kubernetes.default.svc
    namespace: <target-namespace>
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### External Dependencies:
Flag requirements like ServiceMonitor (→Prometheus Operator), ExternalSecrets (→Vault) — **stop and wait for approval**.

---

## Debugging (Read-Only Allowed)

Safe commands for investigation:
```bash
kubectl get pods -n <ns> -o wide
kubectl describe pod <pod-name> -n <ns>
kubectl logs <pod-name> -n <ns> --previous
kubectl get events -n <ns> --sort-by='.lastTimestamp'
argocd app get <app-name>
argocd app diff <app-name>
```

Debug pods (use `--rm`):
```bash
kubectl run -it --rm debug --image=nicolaka/netshoot --restart=Never -n <ns> -- bash
```

---

## Commands

### Terraform:
- `terraform init` - Initialize modules and providers
- `terraform plan` - Preview changes
- `terraform apply -auto-approve` - Apply changes
- `terraform destroy` - Remove resources
- Navigate: `cd terraform/clusters/prod && terraform ...`

### Helm (linting/rendering only):
- `helm template <name> ./<chart-path>` - Render templates locally
- `helm lint ./<chart-path>` - Validate chart
- `helm dependency update ./<chart-path>` - Update Chart.lock

### Scripts:
- `bash scripts/bash/helm-chart-manager.sh` - Helm charts with AWS ECR
- `bash scripts/bash/cloudinit.sh` - Create VM templates

---

## Code Style Guidelines

### Terraform (.tf files)
**Naming:** snake_case (`proxmox_vms_talos`, `cp_vip`)
**Type System:**
```terraform
variable "example" {
  type = map(object({
    id     = number
    name   = string
    cpu    = optional(number, 2)
  }))
}
```
- Use strict `type` with `object()` for complex structures
- Leverage `optional()` for parameters with defaults
- 2-space indentation; empty lines separate logical blocks

### Kubernetes Manifests (.yaml files)
**Naming:** lowercase with hyphens (`cluster-issuer.yaml`)
**Labels:** use `app.kubernetes.io/name`, `app: <name>` conventions
**Patterns:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: <resource-name>
  namespace: <namespace>
spec:
  replicas: 1
  selector:
    matchLabels:
      app: <app-name>
```
- Include `nodeSelector`, `securityContext`, resource requests/limits

### Helm Charts
**Structure:**
```
charts/<name>/
├── Chart.yaml          # Dependencies
├── values.yaml         # Configuration
└── templates/          # Kubernetes manifests
```
- Use `{{ include "app.fullname" . }}` for consistent naming
- Conditional: `{{- with ... }}` blocks

### Docker Compose (.yml files)
```yaml
version: '3.8'
services:
  service-name:
    container_name: <name>
    image: <image>:<tag>
    environment:
      - VAR=value
    ports:
      - "8080:8080"
    restart: unless-stopped
```

### Bash Scripts (.sh files)
```bash
#!/bin/bash
set -e  # Exit on error

auth_ecr() {
    local repo_name="$1"
    if [[ -z "$repo_name" ]]; then
        echo "Error message"
        exit 1
    fi
}
```
- Variables: lowercase with underscores
- Functions: snake_case
- Use `local` for function-scoped variables

---

## Project Structure
```
homelab/
├── docker/           # Docker Compose configurations
├── kubernetes/       # Kubernetes manifests, Helm charts, ArgoCD
│   ├── argocd/
│   │   ├── apps/     # ArgoCD Application manifests
│   │   └── projects/ # ArgoCD Project manifests
│   ├── boilerplates/ # Reusable template files
│   ├── helm-charts/  # Helm chart values and custom charts
│   └── talos/        # Cluster-level resources
├── scripts/          # Automation scripts
└── terraform/        # Infrastructure as Code
    ├── clusters/     # Talos Kubernetes cluster deployment
    ├── proxmox/      # Standalone VM provisioning
    └── talos/        # Complete Talos cluster setup
```

---

## Key Notes
- **ArgoCD tracks `main` only** — feature branches will NOT deploy until merged
- Use `.env` files for sensitive configuration (gitignored)
- External secrets via HashiCorp Vault + external-secrets operator — never commit plaintext secrets
- ArgoCD projects: `infrastructure` (platform tools), `media-stack` (self-hosted apps)