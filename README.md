# 🏡 Kubernetes Homelab Applications Stack

[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.35+-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Helm](https://img.shields.io/badge/Helm-v3.10+-0F1689?logo=helm&logoColor=white)](https://helm.sh/)
[![Portainer](https://img.shields.io/badge/Portainer-2.33.6-13BEF9?logo=portainer&logoColor=white)](https://www.portainer.io/)
[![Jellyfin](https://img.shields.io/badge/Jellyfin-2.7.0-00A4DC?logo=jellyfin&logoColor=white)](https://jellyfin.org/)
[![Pi-hole](https://img.shields.io/badge/Pi--hole-2.35.0-96060C?logo=pihole&logoColor=white)](https://pi-hole.net/)
[![Vaultwarden](https://img.shields.io/badge/Vaultwarden-0.34.4-175DDC?logo=bitwarden&logoColor=white)](https://github.com/dani-garcia/vaultwarden)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Professional Kubernetes deployment for self-hosted applications, featuring secure credential management, automated TLS certificate provisioning, network-wide ad blocking, and password management.

## 🎯 Overview

This repository manages a comprehensive self-hosted application stack including media server (Jellyfin), ROM library manager (ROMM), container management (Portainer), custom web application (Meu Site), network-wide ad blocker (Pi-hole), and password manager (Vaultwarden).

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Self-Hosted Applications                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │Portainer │  │ Jellyfin │  │   ROMM   │  │ Meu Site │  │ Pi-hole  │    │
│  │Container │  │  Media   │  │   ROM    │  │  Custom  │  │  DNS+Ad  │    │
│  │  Mgmt    │  │  Server  │  │ Library  │  │   Web    │  │  Block   │    │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘    │
│       │             │              │             │             │           │
│       │             │              │             │             │           │
│  ┌────┴─────────────┴──────────────┴─────────────┴─────────────┘           │
│  │                    Vaultwarden (Password Manager)                       │
│  └────┬─────────────────────────────────────────────────────────┬──────────┘
│       │                                                         │           │
│       └─────────────────────┬───────────────────────────────────┘           │
│                             │                                               │
│                    ┌────────▼──────────┐                                    │
│                    │  Nginx Ingress    │                                    │
│                    │  + TLS/SSL        │                                    │
│                    └────────┬──────────┘                                    │
│                             │                                               │
│                    ┌────────▼──────────┐                                    │
│                    │   Cert-Manager    │                                    │
│                    │  (Let's Encrypt)  │                                    │
│                    └───────────────────┘                                    │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                         Network Services                                    │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │  Pi-hole DNS Service (LoadBalancer)                              │      │
│  │  - IP: 192.168.1.53 (MetalLB)                                    │      │
│  │  - Port 53 (TCP/UDP) - DNS                                       │      │
│  │  - Port 9617 (TCP) - Prometheus Metrics                          │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                        Secret Management                                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                     │
│  │ External     │→ │  HashiCorp   │  │   Vault KV   │                     │
│  │ Secrets      │  │    Vault     │  │   Secrets    │                     │
│  │ Operator     │  │              │  │              │                     │
│  └──────────────┘  └──────────────┘  └──────────────┘                     │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                        Persistent Storage                                   │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  NFS Server: altaria.henriqzimer.com.br                              │  │
│  │  Path: /mnt/altaria/kubernetes                                       │  │
│  │  - Jellyfin: media library (100Gi)                                   │  │
│  │  - ROMM: config, library, resources (100Gi+)                         │  │
│  │  - Meu Site: MongoDB data (8Gi)                                      │  │
│  │  - Pi-hole: configuration & blocklists (1Gi)                         │  │
│  │  - Vaultwarden: database & attachments (15Gi)                        │  │
│  │  - Portainer: data (10Gi)                                            │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Applications

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
- **Storage**: 10Gi NFS persistent volume

### Jellyfin (v2.7.0)
- **Purpose**: Media server for movies, TV shows, music
- **Namespace**: `jellyfin`
- **Access**: https://jellyfin.henriqzimer.com.br
- **Features**:
  - Multi-format media streaming
  - Hardware transcoding support
  - User management and parental controls
  - Mobile and TV client support
- **Storage**: 
  - Config: 5Gi
  - Media: 100Gi
  - Cache: 10Gi

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
  - Metadata scraping (IGDB, MobyGames, RetroAchievements)
  - Cover art integration
  - Multi-platform support
- **Storage**:
  - Config: 1Gi
  - Library: 100Gi
  - Resources: 10Gi
  - MariaDB: 10Gi

### Meu Site (v1.0.0)
- **Purpose**: Custom web application
- **Namespace**: `meu-site`
- **Access**: https://henriqzimer.com.br
- **Components**:
  - Frontend (React/Next.js)
  - Backend (Node.js/Python)
  - MongoDB database
- **Features**:
  - Personal portfolio/blog
  - Custom functionality
  - RESTful API endpoints
- **Storage**: MongoDB 8Gi

### Pi-hole (v2.35.0)
- **Purpose**: Network-wide ad blocker and DNS server
- **Namespace**: `pihole`
- **Access**: 
  - Web UI: https://pihole-k8s.henriqzimer.com.br/admin
  - DNS Service: 192.168.1.53:53
- **Features**:
  - DNS-based ad blocking
  - Custom DNS records
  - DHCP server (optional)
  - Query logging and statistics
  - Prometheus metrics export
- **Blocklists**:
  - StevenBlack hosts
  - Admiral, Easylist, Easyprivacy
- **DNS Upstream**: Cloudflare (1.1.1.1) + Google (8.8.8.8)
- **Storage**: 1Gi NFS persistent volume
- **Network**: LoadBalancer with MetalLB (IP: 192.168.1.53)

### Vaultwarden (v0.34.4)
- **Purpose**: Self-hosted password manager (Bitwarden-compatible)
- **Namespace**: `vaultwarden`
- **Access**: https://vaultwarden-k8s.henriqzimer.com.br
- **Features**:
  - Bitwarden-compatible API
  - Admin panel
  - SMTP email notifications
  - 2FA/MFA support (TOTP, U2F, Duo, YubiKey)
  - Organization management
  - File attachments
  - Emergency access
- **Security**:
  - Admin token (Argon2 hashed)
  - Encrypted vault storage
  - TLS/HTTPS only
- **Storage**: SQLite database on NFS (15Gi)
- **SMTP**: Configured with Office365

## Quick Start

### Prerequisites

- Kubernetes cluster (v1.35+)
- Helmfile installed
- kubectl configured
- External Secrets Operator deployed
- HashiCorp Vault accessible
- Cert-Manager with Let's Encrypt configured
- NFS server accessible
- MetalLB for LoadBalancer services (Pi-hole DNS)

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
kubectl get pods -n meu-site
kubectl get pods -n pihole
kubectl get pods -n vaultwarden
```

6. **Check ingress and certificates**:
```bash
kubectl get ingress -A
kubectl get certificates -A
```

7. **Verify Pi-hole DNS service**:
```bash
kubectl get svc -n pihole
dig @192.168.1.53 google.com
```

## Configuration

### Persistent Volumes

All applications use NFS persistent storage:

- **NFS Server**: `altaria.henriqzimer.com.br`
- **Base Path**: `/mnt/altaria/kubernetes`
- **Storage Class**: `nfs-static`

Application-specific volumes:
- Portainer: 10Gi at `/mnt/altaria/kubernetes/portainer/app`
- Jellyfin Config: 5Gi at `/mnt/altaria/kubernetes/jellyfin/config`
- Jellyfin Media: 100Gi at `/mnt/altaria/kubernetes/jellyfin/media`
- Jellyfin Cache: 10Gi at `/mnt/altaria/kubernetes/jellyfin/cache`
- ROMM Config: 1Gi at `/mnt/altaria/kubernetes/romm/config`
- ROMM Library: 100Gi at `/mnt/altaria/kubernetes/romm/library`
- ROMM Resources: 10Gi at `/mnt/altaria/kubernetes/romm/resources`
- ROMM MariaDB: 10Gi at `/mnt/altaria/kubernetes/romm/mariadb`
- Meu Site MongoDB: 8Gi at `/mnt/altaria/kubernetes/meu-site/mongodb`
- Pi-hole: 1Gi at `/mnt/altaria/kubernetes/pihole/app`
- Vaultwarden: 15Gi at `/mnt/altaria/kubernetes/vaultwarden/app`

### Secrets Management

All sensitive credentials are managed through HashiCorp Vault:

**ROMM Secrets** (`romm` namespace):
- `romm-credentials`: IGDB, MobyGames, RetroAchievements API keys
- `romm-database-credentials`: MariaDB connection details

**Meu Site Secrets** (`meu-site` namespace):
- `meu-site-database-credentials`: MongoDB connection URI

**Pi-hole Secrets** (`pihole` namespace):
- `pihole-admin-credentials`: Admin panel password

**Vaultwarden Secrets** (`vaultwarden` namespace):
- `vaultwarden-credentials`: Admin token, SMTP credentials

External Secrets automatically sync from Vault paths:
- `secret/data/kubernetes/romm-credentials`
- `secret/data/kubernetes/romm-database-credentials`
- `secret/data/kubernetes/meu-site-database-credentials`
- `secret/data/kubernetes/pihole-admin-credentials`
- `secret/data/kubernetes/vaultwarden-credentials`

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

### Pi-hole

**Issue**: Cannot access DNS service
```bash
# Check LoadBalancer IP
kubectl get svc -n pihole pihole-dns

# Test DNS resolution
dig @192.168.1.53 google.com
nslookup google.com 192.168.1.53

# Check MetalLB assignment
kubectl describe svc -n pihole pihole-dns | grep -A 5 "LoadBalancer Ingress"

# Verify pod status
kubectl logs -n pihole -l app=pihole -c pihole
```

**Issue**: Web admin not accessible
```bash
# Check ingress
kubectl get ingress -n pihole

# Verify certificate
kubectl get certificate -n pihole

# Check admin token secret
kubectl get secret -n pihole pihole-admin-credentials
```

**Issue**: Blocklists not loading
```bash
# Check adlist configuration
kubectl exec -n pihole <pod-name> -- cat /etc/pihole/adlists.list

# Trigger gravity update
kubectl exec -n pihole <pod-name> -- pihole -g

# Check logs
kubectl logs -n pihole <pod-name> -c pihole | grep -i gravity
```

### Vaultwarden

**Issue**: Cannot login to admin panel
```bash
# Verify admin token secret
kubectl get secret -n vaultwarden vaultwarden-credentials
kubectl get externalsecret -n vaultwarden

# Check pod logs
kubectl logs -n vaultwarden vaultwarden-0

# Verify environment variables
kubectl exec -n vaultwarden vaultwarden-0 -- env | grep ADMIN
```

**Issue**: SMTP not working
```bash
# Check SMTP configuration
kubectl describe configmap -n vaultwarden vaultwarden

# Test SMTP credentials
kubectl get secret -n vaultwarden vaultwarden-credentials -o yaml

# Check logs for SMTP errors
kubectl logs -n vaultwarden vaultwarden-0 | grep -i smtp
```

**Issue**: Database not persisting
```bash
# Verify PVC binding
kubectl get pvc -n vaultwarden

# Check NFS mount
kubectl exec -n vaultwarden vaultwarden-0 -- ls -la /data

# Review database file
kubectl exec -n vaultwarden vaultwarden-0 -- ls -lh /data/db.sqlite3
```

### Meu Site

**Issue**: Frontend/Backend connectivity
```bash
# Check service endpoints
kubectl get svc -n meu-site

# Verify ingress paths
kubectl describe ingress -n meu-site

# Test backend API
kubectl exec -n meu-site <frontend-pod> -- curl http://meu-site-backend:5000/api/health

# Check MongoDB connection
kubectl logs -n meu-site <backend-pod> | grep -i mongo
```

**Issue**: MongoDB connection errors
```bash
# Check MongoDB pod
kubectl get pods -n meu-site -l app=database

# Verify connection string
kubectl get secret -n meu-site meu-site-database-credentials -o yaml

# Test database connectivity
kubectl exec -n meu-site <backend-pod> -- nc -zv meu-site-database 27017
```

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
2. **TLS Everywhere**: All ingress endpoints use HTTPS with Let's Encrypt
3. **Network Isolation**: Each application in separate namespace
4. **Resource Limits**: Prevent resource exhaustion attacks
5. **ReadOnly Root Filesystem**: Where applicable
6. **Non-Root Containers**: Run as unprivileged users
7. **Regular Updates**: Keep application versions current
8. **Admin Panel Security**: 
   - Vaultwarden admin token using Argon2 hashing
   - Pi-hole admin password stored in Vault
9. **DNS Security**: Pi-hole blocks malicious domains
10. **Password Management**: Vaultwarden with 2FA/MFA support

## Network Configuration

### DNS Setup (Pi-hole)

To use Pi-hole as your network DNS:

**Option 1: Router Configuration (Recommended)**
- Configure your router's DHCP to use `192.168.1.53` as primary DNS
- All devices on the network will automatically use Pi-hole

**Option 2: Individual Device Configuration**
- Set DNS server to `192.168.1.53` on each device
- Backup DNS: `8.8.8.8` (Google)

**Verify DNS**:
```bash
# From any device
nslookup google.com 192.168.1.53
dig @192.168.1.53 google.com
```

### Accessing Services

All services are accessible via HTTPS:
- **Portainer**: https://portainer.henriqzimer.com.br
- **Jellyfin**: https://jellyfin.henriqzimer.com.br
- **ROMM**: https://romm.henriqzimer.com.br
- **Meu Site**: https://henriqzimer.com.br
- **Pi-hole Admin**: https://pihole-k8s.henriqzimer.com.br/admin
- **Vaultwarden**: https://vaultwarden-k8s.henriqzimer.com.br

**Note**: Ensure DNS records point to your Ingress LoadBalancer IP (192.168.1.50)

## Monitoring

Monitor application health:

```bash
# Check all pods
kubectl get pods -A | grep -E "portainer|jellyfin|romm|meu-site|pihole|vaultwarden"

# View resource usage
kubectl top pods -n portainer
kubectl top pods -n jellyfin
kubectl top pods -n romm
kubectl top pods -n meu-site
kubectl top pods -n pihole
kubectl top pods -n vaultwarden

# Check ingress status
kubectl get ingress -A

# Verify certificate status
kubectl get certificates -A

# Monitor Pi-hole metrics (Prometheus)
curl http://192.168.1.53:9617/metrics

# Check DNS queries
kubectl exec -n pihole <pod-name> -- pihole -c -j
```

## Backup and Recovery

### Database Backups

**ROMM MariaDB**:
```bash
# Manual backup
kubectl exec -n romm <mariadb-pod> -- mysqldump -u root -p<password> romm > romm-backup.sql

# Restore from backup
kubectl exec -i -n romm <mariadb-pod> -- mysql -u root -p<password> romm < romm-backup.sql
```

**Meu Site MongoDB**:
```bash
# Backup MongoDB
kubectl exec -n meu-site <mongodb-pod> -- mongodump --out=/tmp/backup

# Restore MongoDB
kubectl exec -i -n meu-site <mongodb-pod> -- mongorestore /tmp/backup
```

**Vaultwarden SQLite**:
```bash
# Backup Vaultwarden database
kubectl exec -n vaultwarden vaultwarden-0 -- sqlite3 /data/db.sqlite3 ".backup '/data/backup.sqlite3'"

# Copy backup locally
kubectl cp vaultwarden/vaultwarden-0:/data/backup.sqlite3 ./vaultwarden-backup.sqlite3
```

### Application Data

All application data is stored on NFS. Backup the NFS directories:
- `/mnt/altaria/kubernetes/portainer/app`
- `/mnt/altaria/kubernetes/jellyfin/config`
- `/mnt/altaria/kubernetes/jellyfin/media`
- `/mnt/altaria/kubernetes/jellyfin/cache`
- `/mnt/altaria/kubernetes/romm/config`
- `/mnt/altaria/kubernetes/romm/library`
- `/mnt/altaria/kubernetes/romm/resources`
- `/mnt/altaria/kubernetes/romm/mariadb`
- `/mnt/altaria/kubernetes/meu-site/mongodb`
- `/mnt/altaria/kubernetes/pihole/app`
- `/mnt/altaria/kubernetes/vaultwarden/app`

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

