.PHONY: help namespaces pvcs cleanup-pvs secrets helm deploy status validate clean logs-portainer logs-jellyfin logs-romm port-forward-portainer port-forward-jellyfin port-forward-romm

# Colors for output
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
BLUE   := \033[0;34m
RESET  := \033[0m

# Default target
.DEFAULT_GOAL := help

help: ## Display this help message
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(RESET)"
	@echo "$(BLUE)  Home Applications Stack - Makefile Help$(RESET)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Usage:$(RESET)"
	@echo "  make $(GREEN)deploy$(RESET)        # Full deployment from scratch"
	@echo "  make $(GREEN)status$(RESET)        # Check deployment status"
	@echo "  make $(GREEN)validate$(RESET)      # Validate configurations"
	@echo "  make $(GREEN)clean$(RESET)         # Clean up all resources"
	@echo ""

namespaces: ## Create namespaces
	@echo "$(BLUE)📦 Creating namespaces...$(RESET)"
	@kubectl apply -f manifests/namespace.yaml
	@echo "$(GREEN)✅ Namespaces created$(RESET)"
	@echo ""

cleanup-pvs: ## Release PersistentVolumes stuck in Released state
	@echo "$(BLUE)🔧 Checking and releasing PersistentVolumes...$(RESET)"
	@for pv in portainer-pv jellyfin-pv romm-pv; do \
		if kubectl get pv $$pv >/dev/null 2>&1; then \
			STATUS=$$(kubectl get pv $$pv -o jsonpath='{.status.phase}'); \
			if [ "$$STATUS" = "Released" ]; then \
				echo "  $(YELLOW)🔓 Releasing $$pv...$(RESET)"; \
				kubectl patch pv $$pv --type json -p '[{"op": "remove", "path": "/spec/claimRef"}]' 2>/dev/null || true; \
			fi; \
		fi; \
	done
	@echo "$(GREEN)✅ PersistentVolumes checked$(RESET)"
	@echo ""

pvcs: cleanup-pvs ## Create PersistentVolumes and PersistentVolumeClaims
	@echo "$(BLUE)📦 Creating PersistentVolumes and PersistentVolumeClaims...$(RESET)"
	@kubectl apply -f manifests/persistent-volume.yaml
	@kubectl apply -f manifests/persistent-volume-claim.yaml
	@echo "$(GREEN)✅ PVs and PVCs created$(RESET)"
	@echo ""

secrets: ## Apply ExternalSecrets for retrieving secrets from Vault
	@echo "$(BLUE)🔐 Applying ExternalSecrets...$(RESET)"
	@kubectl apply -f manifests/external-secrets.yaml
	@echo "$(GREEN)✅ ExternalSecrets applied$(RESET)"
	@echo "$(YELLOW)⚠️  Note: Secrets will be created once External Secrets Operator is running$(RESET)"
	@echo ""

helm: namespaces pvcs secrets ## Deploy applications using Helmfile
	@echo "$(BLUE)🚀 Deploying applications with Helmfile...$(RESET)"
	@helmfile apply
	@echo ""
	@echo "$(BLUE)⏳ Waiting for deployments to be ready...$(RESET)"
	@sleep 10
	@echo "$(GREEN)✅ Helmfile deployment completed$(RESET)"
	@echo ""

deploy: helm ## Full deployment (creates everything)
	@echo ""
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════$(RESET)"
	@echo "$(GREEN)  ✅ Home Applications Deployment Completed!$(RESET)"
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════$(RESET)"
	@echo ""
	@echo "$(YELLOW)Next steps:$(RESET)"
	@echo "  1. Check status: make status"
	@echo "  2. Validate: make validate"
	@echo "  3. View logs: make logs-<service>"
	@echo ""

status: ## Check deployment status
	@echo "$(BLUE)📊 Checking deployment status...$(RESET)"
	@echo ""
	@echo "$(YELLOW)Namespaces:$(RESET)"
	@kubectl get namespaces | grep -E '(portainer|jellyfin|romm)' || echo "  No namespaces found"
	@echo ""
	@echo "$(YELLOW)Pods:$(RESET)"
	@kubectl get pods -n portainer -o wide 2>/dev/null || echo "  Portainer namespace not found"
	@kubectl get pods -n jellyfin -o wide 2>/dev/null || echo "  Jellyfin namespace not found"
	@kubectl get pods -n romm -o wide 2>/dev/null || echo "  ROMM namespace not found"
	@echo ""
	@echo "$(YELLOW)PersistentVolumeClaims:$(RESET)"
	@kubectl get pvc -A | grep -E '(portainer|jellyfin|romm)' || echo "  No PVCs found"
	@echo ""
	@echo "$(YELLOW)Ingress:$(RESET)"
	@kubectl get ingress -A | grep -E '(portainer|jellyfin|romm)' || echo "  No Ingress found"
	@echo ""

validate: ## Validate Kubernetes manifests
	@echo "$(BLUE)🔍 Validating Kubernetes manifests...$(RESET)"
	@echo ""
	@for file in manifests/*.yaml manifests/**/*.yaml; do \
		if [ -f "$$file" ]; then \
			echo "$(YELLOW)Validating $$file...$(RESET)"; \
			kubectl apply --dry-run=client -f "$$file" >/dev/null 2>&1 && \
				echo "$(GREEN)  ✓ Valid$(RESET)" || \
				echo "$(RED)  ✗ Invalid$(RESET)"; \
		fi; \
	done
	@echo ""
	@echo "$(GREEN)✅ Validation completed$(RESET)"
	@echo ""

clean: ## Clean up all resources (WARNING: Destructive operation!)
	@echo "$(RED)⚠️  WARNING: This will delete all home applications stack resources!$(RESET)"
	@echo "$(YELLOW)Press Ctrl+C to cancel, or wait 5 seconds to continue...$(RESET)"
	@sleep 5
	@echo ""
	@echo "$(BLUE)🗑️  Removing Helm releases...$(RESET)"
	@helmfile destroy || true
	@echo ""
	@echo "$(BLUE)🗑️  Deleting PVCs...$(RESET)"
	@kubectl delete -f manifests/persistent-volume-claim.yaml --ignore-not-found=true || true
	@echo ""
	@echo "$(BLUE)🗑️  Deleting PVs...$(RESET)"
	@kubectl delete -f manifests/persistent-volume.yaml --ignore-not-found=true || true
	@echo ""
	@echo "$(BLUE)🗑️  Deleting ExternalSecrets...$(RESET)"
	@kubectl delete -f manifests/external-secrets.yaml --ignore-not-found=true || true
	@echo ""
	@echo "$(BLUE)🗑️  Deleting namespaces...$(RESET)"
	@kubectl delete -f manifests/namespace.yaml --ignore-not-found=true || true
	@echo ""
	@echo "$(GREEN)✅ Cleanup completed$(RESET)"
	@echo ""

logs-portainer: ## Show Portainer logs
	@kubectl logs -f -n portainer deployment/portainer

logs-jellyfin: ## Show Jellyfin logs
	@kubectl logs -f -n jellyfin deployment/jellyfin

logs-romm: ## Show ROMM logs
	@kubectl logs -f -n romm deployment/romm

port-forward-portainer: ## Port-forward to Portainer (localhost:9443)
	@echo "$(BLUE)🔌 Port-forwarding to Portainer on https://localhost:9443$(RESET)"
	@kubectl port-forward -n portainer svc/portainer 9443:9443

port-forward-jellyfin: ## Port-forward to Jellyfin (localhost:8096)
	@echo "$(BLUE)🔌 Port-forwarding to Jellyfin on http://localhost:8096$(RESET)"
	@kubectl port-forward -n jellyfin svc/jellyfin 8096:8096

port-forward-romm: ## Port-forward to ROMM (localhost:8085)
	@echo "$(BLUE)🔌 Port-forwarding to ROMM on http://localhost:8085$(RESET)"
	@kubectl port-forward -n romm svc/romm 8085:80
