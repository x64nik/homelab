# Homelab Infrastructure - Agent Guidelines

## Overview
This repository contains infrastructure-as-code for a personal homelab setup, using Terraform, Kubernetes (Talos), Helm charts, and Docker Compose. No traditional build/lint/test commands exist.

## Detailed Rule Files
> These files contain the full, detailed rules for specific domains. **Read the relevant file before starting any task in that area.**

| Task Area | Rule File |
|---|---|
| Any Kubernetes deployment, Helm chart, ArgoCD, GitOps | `.opencode/rules/kubernetes.md` |
---

## ⚠️ CRITICAL — Kubernetes GitOps Rules (Read Before ANY K8s Task)

> These rules are **non-negotiable** and override any generic Helm/kubectl commands listed elsewhere in this file.

### NEVER do any of the following directly:
- `helm install` / `helm upgrade --install` — **FORBIDDEN for deployments**
- `kubectl apply` to deploy or fix workloads
- `kubectl edit` / `kubectl patch` / `kubectl delete` on live objects
- Install operators, CRDs, or any external dependency not explicitly approved

### ALWAYS follow this flow for any Kubernetes deployment or change:
1. Create/update Helm values → `./kubernetes/helm-charts/<app-name>/values.yaml`
2. Create/update ArgoCD Application manifest → `./kubernetes/argocd/apps/<app-name>/`
3. Create a new project in `./kubernetes/argocd/projects/` **only if** no existing project fits — reuse `infrastructure` or `media-stack` first
4. Commit changes to a **feature branch** using naming: `opencode/<task>/<feature>`
5. Raise a PR → **wait for user approval** → merge to `main`
6. Only after merge to `main` verify ArgoCD sync — ArgoCD tracks `main` branch only

### ArgoCD Application Template (always use this skeleton):
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: <app-name>
  namespace: argocd
spec:
  project: <existing-project>   # use 'infrastructure' or 'media-stack' unless a new one is justified
  source:
    repoURL: <repo-url>
    targetRevision: main         # ALWAYS main, never a feature branch
    path: kubernetes/helm-charts/<app-name>
    helm:
      valueFiles:
        - values.yaml
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
- If a feature requires an external dependency (e.g., ServiceMonitor → Prometheus Operator, metrics → kube-state-metrics), **flag it and stop** — do not add it until the user explicitly approves.

---

## ⚠️ CRITICAL — Kubernetes Debugging Rules

> Use `kubectl` freely for **read-only investigation**. All fixes must still go through GitOps above.

### Safe read-only commands:
```bash
kubectl get pods -n <namespace> -o wide
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
kubectl get pvc,svc,ingress,certificate -n <namespace>
argocd app get <app-name>
argocd app diff <app-name>
```

### Temporary debug pods (allowed, always use --rm):
```bash
kubectl run -it --rm debug --image=nicolaka/netshoot --restart=Never -n <namespace> -- bash
```

### After identifying the issue:
- Fix via template changes in `./kubernetes/helm-charts/` or `./kubernetes/talos/`
- Follow the GitOps flow above — never patch live objects

---

## Commands

### Terraform Operations
- `terraform init` - Initialize modules and download providers
- `terraform plan` - Preview changes before applying
- `terraform apply -auto-approve` - Apply infrastructure changes
- `terraform destroy` - Remove all managed resources
- Navigate to specific directory: `cd terraform/clusters/prod && terraform ...`

### Kubernetes/Helm — Utility Commands Only (NOT for deployments)
> ⚠️ The commands below are for **local linting/rendering only** — never for direct deployment.
- `helm template <name> ./<chart-path>` - Render templates locally to verify output
- `helm lint ./<chart-path>` - Lint chart before committing
- `helm dependency update ./<chart-path>` - Update Chart.lock after adding subcharts
- `argocd app get <app-name>` - Check ArgoCD app status
- `argocd app diff <app-name>` - Check diff before sync

### Scripts
- `bash scripts/bash/helm-chart-manager.sh` - Manage Helm charts with AWS ECR integration
- `bash scripts/bash/cloudinit.sh` - Create VM templates
- `bash scripts/bash/fe_entrypoint.sh` - Replace NGINX config placeholders

---

## Code Style Guidelines

### Terraform (.tf files)
**Naming:**
- Variables: snake_case (`proxmox_vms_talos`, `cp_vip`)
- Resources: snake_case with descriptive names (`resource "helm_release" "chart"`)
- Modules: lowercase with hyphens in paths (`modules/vm`, `modules/cluster`)

**Type System:**
```terraform
variable "example" {
  type = map(object({
    id     = number
    name   = string
    cpu    = optional(number, 2)  # Optional with default
  }))
}
```
- Use strict `type` definitions with `object()` for complex structures
- Leverage `optional()` for parameters with defaults

**Formatting:**
- 2-space indentation
- Empty lines separate logical blocks (provider, variables, resources, outputs)
- Comments explain sections: `# Configure provider in root module`

### Kubernetes Manifests (.yaml files)
**Naming:**
- Resource names: lowercase with hyphens (`cluster-issuer.yaml`)
- Labels follow standard conventions (`app.kubernetes.io/name`, `app: jellyfin`)
- Container names: lowercase and descriptive

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
- Use `nodeSelector` for node affinity
- Define `securityContext` with non-root users
- Include resource requests/limits

### Helm Charts
**Structure:**
```
charts/<name>/
├── Chart.yaml          # Definition with dependencies
├── values.yaml         # Configuration
└── templates/          # Kubernetes manifests
```

**Template Patterns:**
- Use `{{ include "app.fullname" . }}` for consistent naming
- Conditional rendering: `{{- with ... }}` blocks
- Follow Helm best practices with `include` and `tpl` functions

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
- Service names: lowercase with hyphens
- Environment variables: uppercase with underscores

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
- Use `local` keyword for function-scoped variables
- Error handling with `set -e` and explicit checks

---

## Project Structure
```
homelab/
├── docker/           # Docker Compose configurations
├── kubernetes/       # Kubernetes manifests, Helm charts, ArgoCD
│   ├── argocd/
│   │   ├── apps/     # ArgoCD Application manifests (one folder per app)
│   │   └── projects/ # ArgoCD Project manifests
│   ├── boilerplates/ # Reusable template files
│   ├── helm-charts/  # Helm chart values and custom charts
│   └── talos/        # Cluster-level resources (issuers, gateways, etc.)
├── scripts/          # Automation scripts
└── terraform/        # Infrastructure as Code
    ├── clusters/     # Talos Kubernetes cluster deployment
    ├── proxmox/      # Standalone VM provisioning
    └── talos/        # Complete Talos cluster setup
```

## Key Notes
- No CI/CD workflows present; deployment is manual or via ArgoCD GitOps
- Use `.env` files for sensitive configuration (gitignored)
- External secrets managed via HashiCorp Vault + external-secrets operator — never commit plaintext secrets
- All services use consistent naming and organizational patterns
- ArgoCD tracks the **main** branch — feature branch changes will NOT be deployed until merged