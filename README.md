# 🏡 Kubernetes Homelab Applications Stack

[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.25+-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Helm](https://img.shields.io/badge/Helm-v3.10+-0F1689?logo=helm&logoColor=white)](https://helm.sh/)
[![Portainer](https://img.shields.io/badge/Portainer-2.33.6-13BEF9?logo=portainer&logoColor=white)](https://www.portainer.io/)
[![Jellyfin](https://img.shields.io/badge/Jellyfin-2.7.0-00A4DC?logo=jellyfin&logoColor=white)](https://jellyfin.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Professional Kubernetes deployment for self-hosted media and management applications, featuring secure credential management and automated TLS certificate provisioning.

## 🎯 Overview

This repository manages self-hosted applications including media server (Jellyfin), ROM library manager (ROMM), and container management platform (Portainer).

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Self-Hosted Applications                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │  Portainer   │  │   Jellyfin   │  │     ROMM     │    │
│  │  Container   │  │  Media       │  │  ROM Library │    │
│  │  Management  │  │  Server      │  │  Manager     │    │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │
│         │                 │                  │             │
│         └─────────────────┴──────────────────┘             │
│                           │                                │
│                  ┌────────▼──────────┐                     │
│                  │  Nginx Ingress    │                     │
│                  │  + TLS/SSL        │                     │
│                  └────────┬──────────┘                     │
│                           │                                │
│                  ┌────────▼──────────┐                     │
│                  │   Cert-Manager    │                     │
│                  │  (Let's Encrypt)  │                     │
│                  └───────────────────┘                     │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                    Secret Management                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │ External     │→ │  HashiCorp   │  │   Vault KV   │    │
│  │ Secrets      │  │    Vault     │  │   Secrets    │    │
│  │ Operator     │  │              │  │              │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                     Persistent Storage                      │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  NFS Server: altaria.henriqzimer.com.br              │  │
│  │  Path: /mnt/altaria/kubernetes                       │  │
│  │  - Jellyfin media library                            │  │
│  │  - ROMM database (MariaDB)                           │  │
│  │  - Portainer data                                    │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Applications

### Portainer (v2.33.6)
- **Purpose**: Web-based container management UI
- **Namespace**: `portainer`
- **Access**: https://portainer.henriqzimer.com.br
- **Features**:
  - Docker and Kubernetes management
  - Container lifecycle control
  - Image registry management
  - Volume and network administration

### Jellyfin (v2.7.0)
- **Purpose**: Media server for movies, TV shows, music
- **Namespace**: `jellyfin`
- **Access**: https://jellyfin.henriqzimer.com.br
- **Features**:
  - Multi-format media streaming
  - Hardware transcoding support
  - User management and parental controls
  - Mobile and TV client support

### ROMM (v1.0.4)
- **Purpose**: ROM library manager and database
- **Namespace**: `romm`
- **Access**: https://romm.henriqzimer.com.br
- **Components**:
  - ROMM application (ROM management)
  - MariaDB database (persistent storage)
  - Web interface for library organization
- **Features**:
  - ROM collection management
  - Metadata scraping
  - Cover art integration
  - Multi-platform support

## Quick Start

### Prerequisites

- Kubernetes cluster (v1.25+)
- Helmfile installed
- kubectl configured
- External Secrets Operator deployed
- HashiCorp Vault accessible
- Cert-Manager with Let's Encrypt configured
- NFS server accessible

### Deployment

1. **Review namespace configuration**:
```bash
kubectl apply -f manifests/namespace.yaml
```

2. **Configure persistent storage**:
```bash
kubectl apply -f manifests/persistent-volume.yaml
kubectl apply -f manifests/persistent-volume-claim.yaml
```

3. **Deploy External Secrets**:
```bash
kubectl apply -f manifests/external-secrets.yaml
```

4. **Deploy all applications**:
```bash
make apply
# or
helmfile apply
```

5. **Verify deployment**:
```bash
kubectl get pods -n portainer
kubectl get pods -n jellyfin
kubectl get pods -n romm
```

6. **Check ingress and certificates**:
```bash
kubectl get ingress -A
kubectl get certificates -A
```

## Configuration

### Persistent Volumes

All applications use NFS persistent storage:

- **NFS Server**: `altaria.henriqzimer.com.br`
- **Base Path**: `/mnt/altaria/kubernetes`
- **Storage Class**: `nfs-static`

Application-specific volumes:
- Portainer: 10Gi at `/mnt/altaria/kubernetes/portainer-pv`
- Jellyfin: 100Gi at `/mnt/altaria/kubernetes/jellyfin-pv`
- ROMM: 50Gi at `/mnt/altaria/kubernetes/romm-pv`
- MariaDB: 20Gi at `/mnt/altaria/kubernetes/mariadb-pv`

### Secrets Management

All sensitive credentials are managed through HashiCorp Vault:

**ROMM Secrets** (`romm` namespace):
- `romm-db-credentials`: Database passwords
- `romm-app-secrets`: Application authentication keys

**Portainer Secrets** (`portainer` namespace):
- `portainer-admin-credentials`: Admin password

**Jellyfin Secrets** (`jellyfin` namespace):
- `jellyfin-config`: Application configuration

External Secrets automatically sync from Vault paths:
- `secret/data/kubernetes/romm/*`
- `secret/data/kubernetes/portainer/*`
- `secret/data/kubernetes/jellyfin/*`

### TLS Certificates

All applications use cert-manager with Let's Encrypt:
- **Cluster Issuer**: `letsencrypt-prod`
- **Certificate**: Wildcard `*.henriqzimer.com.br`
- **Secret**: `wildcard-henriqzimer-tls`
- **Auto-renewal**: 60 days before expiration

## Makefile Commands

Common operations via `make`:

```bash
# Deploy or upgrade all applications
make apply

# Show deployment diff
make diff

# Destroy all applications
make destroy

# List deployed releases
make list

# Sync with desired state
make sync

# Create namespaces
make namespace

# Deploy persistent volumes
make persistent-volume
make persistent-volume-claim

# Deploy External Secrets
make external-secrets
```

## Troubleshooting

### Portainer

**Issue**: Portainer pod not starting
```bash
# Check pod status
kubectl describe pod -n portainer -l app.kubernetes.io/name=portainer

# Check persistent volume
kubectl get pv portainer-pv
kubectl get pvc -n portainer

# Verify NFS mount
kubectl logs -n portainer <pod-name>
```

**Issue**: Cannot access Portainer UI
```bash
# Verify ingress
kubectl get ingress -n portainer

# Check certificate
kubectl describe certificate -n portainer

# Test ingress controller
kubectl get svc -n ingress-nginx
```

### Jellyfin

**Issue**: Media not appearing
```bash
# Check persistent volume mount
kubectl exec -it -n jellyfin <pod-name> -- ls -la /media

# Verify NFS server connectivity
kubectl exec -it -n jellyfin <pod-name> -- ping altaria.henriqzimer.com.br

# Check library scan logs
kubectl logs -n jellyfin <pod-name> -f
```

**Issue**: Transcoding not working
```bash
# Check hardware acceleration support
kubectl describe pod -n jellyfin <pod-name>

# Review resource limits
kubectl get pod -n jellyfin <pod-name> -o yaml | grep -A 10 resources
```

### ROMM

**Issue**: Database connection failed
```bash
# Verify MariaDB pod
kubectl get pods -n romm -l app=mariadb

# Check database credentials from Vault
kubectl get externalsecrets -n romm
kubectl describe externalsecret -n romm romm-db-credentials

# Test database connectivity
kubectl exec -it -n romm <romm-pod> -- nc -zv mariadb 3306
```

**Issue**: ROMM application errors
```bash
# Check application logs
kubectl logs -n romm -l app=romm -f

# Verify environment variables
kubectl exec -it -n romm <pod-name> -- env | grep ROMM

# Check External Secret sync
kubectl get externalsecret -n romm -w
```

### General Issues

**Certificate not issuing**:
```bash
# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager

# Verify ClusterIssuer
kubectl describe clusterissuer letsencrypt-prod

# Check certificate request
kubectl get certificaterequest -A
kubectl describe certificaterequest -n <namespace> <name>
```

**NFS mount failures**:
```bash
# Verify NFS server accessibility
ping altaria.henriqzimer.com.br

# Check NFS exports
showmount -e altaria.henriqzimer.com.br

# Review PV status
kubectl describe pv <pv-name>
```

**External Secrets not syncing**:
```bash
# Verify Vault connectivity
kubectl logs -n external-secrets deployment/external-secrets

# Check ClusterSecretStore
kubectl describe clustersecretstore vault-backend

# Test Vault authentication
kubectl get sa -n external-secrets
```

## Security Best Practices

1. **No Hardcoded Credentials**: All secrets managed via Vault
2. **TLS Everywhere**: All ingress endpoints use HTTPS
3. **Network Policies**: Restrict pod-to-pod communication
4. **Resource Limits**: Prevent resource exhaustion
5. **ReadOnly Root Filesystem**: Where applicable
6. **Non-Root Containers**: Run as unprivileged users
7. **Regular Updates**: Keep application versions current

## Monitoring

Monitor application health:

```bash
# Check all pods
kubectl get pods -A | grep -E "portainer|jellyfin|romm"

# View resource usage
kubectl top pods -n portainer
kubectl top pods -n jellyfin
kubectl top pods -n romm

# Check ingress status
kubectl get ingress -A

# Verify certificate status
kubectl get certificates -A
```

## Backup and Recovery

### Database Backups (ROMM MariaDB)

```bash
# Manual backup
kubectl exec -n romm <mariadb-pod> -- mysqldump -u root -p<password> romm > romm-backup.sql

# Restore from backup
kubectl exec -i -n romm <mariadb-pod> -- mysql -u root -p<password> romm < romm-backup.sql
```

### Application Data

All application data is stored on NFS. Backup the NFS directories:
- `/mnt/altaria/kubernetes/portainer-pv`
- `/mnt/altaria/kubernetes/jellyfin-pv`
- `/mnt/altaria/kubernetes/romm-pv`
- `/mnt/altaria/kubernetes/mariadb-pv`

## Architecture Decisions

### Why Helm + Helmfile?
- **Declarative Management**: GitOps-friendly configuration
- **Version Control**: Track application versions
- **Templating**: Reusable configuration patterns
- **Dependency Management**: Automatic chart dependency resolution

### Why External Secrets?
- **Security**: Credentials never in Git
- **Centralization**: Single source of truth (Vault)
- **Automation**: Automatic secret rotation
- **Audit Trail**: Vault access logging

### Why NFS Storage?
- **Simplicity**: Easy to manage and backup
- **Performance**: Good for media streaming
- **Multi-attach**: ReadWriteMany for media libraries
- **Cost**: Utilize existing infrastructure

## License

This project is proprietary. All rights reserved.

---

**Note**: Ensure all secrets are properly configured in HashiCorp Vault before deployment. Never commit sensitive credentials to version control.

