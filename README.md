# Homelab Infrastructure

A collection of infrastructure-as-code for my personal homelab setup.

## Structure

- **`docker/`** - Docker Compose configurations for various services
- **`kubernetes/`** - Kubernetes manifests, Helm charts, and ArgoCD applications
- **`terraform/`** - Infrastructure provisioning with three main environments:
  - `clusters/` - Talos Kubernetes cluster deployment on Proxmox
  - `proxmox/` - Standalone VM provisioning on Proxmox
  - `talos/` - Complete Talos cluster setup with networking (Cilium)

### Terraform Module Structure

```
terraform/
├── clusters/                    # Production Talos cluster
│   ├── modules/
│   │   ├── vm/                 # Proxmox VM provisioning for Talos nodes
│   │   │   ├── Downloads Talos OS images
│   │   │   ├── Creates VMs with proper networking
│   │   │   └── Configures boot order and storage
│   │   ├── cluster/            # Talos cluster configuration
│   │   │   ├── Generates machine secrets
│   │   │   ├── Applies control plane configs
│   │   │   ├── Applies worker node configs
│   │   │   ├── Bootstraps the cluster
│   │   │   └── Retrieves kubeconfig
│   │   ├── helm/               # Helm chart deployment
│   │   │   ├── Deploys charts from repositories
│   │   │   ├── Manages namespaces
│   │   │   └── Handles upgrades and rollbacks
│   │   └── cilium/             # Cilium networking setup
│   │       ├── Creates load balancer IP pools
│   │       └── Configures L2 announcement policies
│   └── prod/                   # Production environment config
├── proxmox/                    # Standalone VM management
│   └── vm/                     # Generic VM provisioning
│       ├── Downloads OS images
│       ├── Creates VMs with custom configs
│       └── Handles GPU passthrough
└── talos/                      # Complete cluster setup
    └── inferno/                # Full Talos cluster with networking
        ├── modules/            # Same modules as clusters/
        └── templates/          # Kubernetes manifests
            ├── cilium.yaml
            ├── metrics-server.yaml
            ├── openebs.yaml
            └── traefik.yaml
```

### MyFlix Helm Chart Structure

```
kubernetes/helm-charts/myflix/          # Custom media stack umbrella chart
├── Chart.yaml                         # Main chart definition with dependencies
├── values.yaml                        # Global configuration for all services
├── myflix-1.0.0.tgz                   # Packaged chart
└── charts/                            # Sub-charts (dependencies)
    ├── jellyfin/                      # Media server
    │   ├── Chart.yaml                 # Jellyfin chart definition
    │   ├── values.yaml                # Jellyfin configuration
    │   └── templates/                 # Kubernetes manifests
    │       ├── deployment.yaml        # Pod deployment
    │       ├── service.yaml           # Service exposure
    │       ├── ingress.yaml           # External access via Traefik
    │       ├── pv.yaml               # Persistent volume (NFS)
    │       ├── pvc.yaml              # Volume claim
    │       ├── storageclass.yaml     # Storage class definition
    │       ├── configmap.yaml        # Configuration data
    │       ├── hpa.yaml              # Horizontal pod autoscaler
    │       └── servicemonitor.yaml   # Prometheus monitoring
    ├── jellyseerr/                    # Request management
    ├── radarr/                        # Movie collection
    ├── sonarr/                        # TV show collection
    ├── prowlarr/                      # Indexer management
    ├── jackett/                       # Torrent indexer
    └── qbittorrent/                   # Download client
```

**MyFlix Architecture:**
- **Umbrella Chart**: Orchestrates 7 media-related services
- **Shared Storage**: All services use NFS-backed persistent volumes
- **Ingress**: Traefik-based routing with subdomain/path-based access
- **Monitoring**: ServiceMonitor integration for Prometheus
- **Auto-scaling**: HPA support for dynamic scaling
- **Configuration**: Timezone and service-specific settings via ConfigMaps

**Service Flow:**
1. **Jellyseerr** → User requests media
2. **Prowlarr** → Manages indexers and searches
3. **Radarr/Sonarr** → Monitors and manages media libraries
4. **Jackett** → Provides torrent indexer APIs
5. **qBittorrent** → Downloads content
6. **Jellyfin** → Streams media to users

- **`scripts/`** - Automation and utility scripts

## Services

### Docker Services
- Media stack (Jellyfin, etc.)
- Databases (PostgreSQL, MySQL, MongoDB, Redis)
- Monitoring (Dozzle)
- Storage (MinIO)
- Development tools (SonarQube, RabbitMQ, ClickHouse)

### Kubernetes
- ArgoCD for GitOps
- Monitoring stack (Prometheus, Grafana)
- Storage (Longhorn)
- Ingress (Traefik)
- Various self-hosted applications

## Getting Started

1. Review the specific service directories for setup instructions
2. Configure environment variables as needed
3. Deploy using Docker Compose or Kubernetes manifests

## Notes

- This is a personal homelab setup
- Adjust configurations for your environment
- Some services may require additional setup or credentials