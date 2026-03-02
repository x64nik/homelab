# OpenCode Rules — `./kubernetes`

> These rules apply to all work inside the `./kubernetes` directory of this GitOps repository.
> ArgoCD is connected to the **main** branch of this repo.

---

## 1. Consistent Template Structure

All Kubernetes manifests and Helm values must follow a consistent layout:

- **Helm chart values** → `./kubernetes/helm-charts/<app-name>/values.yaml`
- **ArgoCD Application manifests** → `./kubernetes/argocd/apps/<app-name>/`
- **ArgoCD Project manifests** → `./kubernetes/argocd/projects/<project-name>.yaml`
- **Cluster-level resources** (Issuers, ExternalSecrets, GatewayClass, etc.) → `./kubernetes/talos/<cluster-name>/`
- Always include `namespace`, `labels`, and `annotations` consistently across all resources.
- Use `app.kubernetes.io/` label conventions (`name`, `instance`, `component`, `managed-by`).

---

## 2. GitOps-First Approach — No Manual Installs

- **Never** `kubectl apply` or `helm install` anything directly unless explicitly instructed.
- All deployments must go through an **ArgoCD Application** manifest committed to the repo.
- To deploy a new app:
  1. Create/update Helm values in `./kubernetes/helm-charts/<app-name>/values.yaml`.
  2. Create an ArgoCD Application in `./kubernetes/argocd/apps/<app-name>/`.
  3. Commit to a branch → raise a PR → wait for approval → merge to `main`.
  4. Only after merge to `main` can ArgoCD sync or a manual sync be triggered.
- **Never modify live Kubernetes objects directly** — always fix via template changes through GitOps.

---

## 3. ArgoCD Application & Project Templates

### Application Template Rules
- All ArgoCD app templates must reference **`targetRevision: main`** (not HEAD, not a feature branch).
- `repoURL` must point to the main repo.
- Values files and chart paths must reference their `./kubernetes/helm-charts/<app>/` location.
- Example skeleton:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: <app-name>
  namespace: argocd
spec:
  project: <project-name>
  source:
    repoURL: <repo-url>
    targetRevision: main
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

### Project Template Rules
- **Reuse existing projects** (`infrastructure`, `media-stack`) whenever the app fits their scope.
- Only create a **new project** when the app clearly belongs to a different domain not covered by existing projects.
- Existing projects:
  - `infrastructure` → platform/infra tools (cert-manager, cilium, vault, traefik, etc.)
  - `media-stack` → media/self-hosted apps (myflix, homarr, open-webui, etc.)

---

## 4. Branch Naming Convention

```
opencode/<task>/<feature-in-task>
```

- One branch per task/feature.
- If multiple features exist in the same task, create separate branches per feature **or** reuse the same branch if changes are in the same task/feature scope.
- Examples:
  - `opencode/add-qdrant/argocd-app`
  - `opencode/grafana-update/add-dashboard`
  - `opencode/myflix/add-subchart-radarr`

---

## 5. Helm Subchart / Dependency Management

When adding a new subchart to an existing umbrella chart (e.g., `myflix`, `grafana-victoria-stack`):

1. Follow the **exact same** values structure and indentation pattern as the parent chart.
2. Add the dependency entry to `Chart.yaml`.
3. Run `helm dependency update` (or `helm package -u .`) to regenerate `Chart.lock` and download charts.
4. Lint before committing:
   ```bash
   helm lint ./kubernetes/helm-charts/<chart-name>
   helm template <release-name> ./kubernetes/helm-charts/<chart-name>
   ```
5. Commit the updated `Chart.lock` and any new `charts/` tarballs alongside the values changes.

---

## 6. External Dependencies — Do Not Install Without Approval

- **Never install** an external dependency (operator, CRD, Helm chart) that was not explicitly requested.
- If a feature requires an external dependency (e.g., ServiceMonitor requires Prometheus Operator), **flag it explicitly** and wait for approval before adding it.
- Document required external dependencies clearly in PR descriptions.

---

## 7. Applying Changes — PR & Merge Flow

```
feature branch  →  PR  →  approval  →  merge to main  →  ArgoCD syncs
```

1. All changes go into a branch following the naming convention above.
2. Raise a PR and **wait for explicit approval** before merging.
3. Only after the PR is merged to `main` should an ArgoCD sync be triggered or verified.
4. **Never apply templates from a feature branch** — ArgoCD tracks `main` only.

---

## 8. ArgoCD Health Checks

- After a deployment, always verify the ArgoCD Application status:
  - App is `Synced` and `Healthy`.
  - No degraded or missing resources.
- If the app shows errors, investigate via ArgoCD UI/CLI and fix through template changes committed to `main` via the GitOps flow — **never patch resources directly**.

---

## 9. Secrets Management

- Secrets must use **ExternalSecret** resources referencing Vault (HashiCorp Vault via `external-secrets` operator).
- Never commit plaintext secrets to the repository.
- External secret templates go alongside the chart values: `./kubernetes/helm-charts/<app>/external-secrets.yaml`.

---

## 10. Summary Checklist (Before Every PR)

- [ ] Template structure follows conventions (`helm-charts/`, `argocd/apps/`, `argocd/projects/`)
- [ ] ArgoCD app references `targetRevision: main`
- [ ] Correct existing project used (or new project justified)
- [ ] Branch name follows `opencode/<task>/<feature>` convention
- [ ] No external dependencies added without approval
- [ ] `helm lint` and `helm template` pass cleanly
- [ ] `Chart.lock` updated if subcharts were added/changed
- [ ] No plaintext secrets committed
- [ ] Changes are **not** applied from a feature branch — PR merged to `main` first