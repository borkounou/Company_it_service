.PHONY: help install ssl deploy update stop restart logs status clean health backup

# Couleurs pour les messages
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

help: ## Afficher l'aide
	@echo "$(BLUE)═══════════════════════════════════════════$(NC)"
	@echo "$(GREEN)  Mahrasoft.com - Commandes disponibles$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(BLUE)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

install: ## Installer les prérequis
	@echo "$(YELLOW)📦 Installation des prérequis...$(NC)"
	@chmod +x Backend/scripts/*.sh
	@mkdir -p logs/nginx
	@mkdir -p /mnt/storage/docker/mahrasoft/uploads
	@mkdir -p /mnt/storage/docker/mahrasoft/static
	@mkdir -p Backend/nginx/ssl
	@echo "$(GREEN)✅ Installation terminée$(NC)"

ssl: ## Configurer les certificats SSL
	@echo "$(YELLOW)🔐 Configuration SSL...$(NC)"
	@./Backend/scripts/setup_ssl.sh

deploy: ## Déployer l'application
	@echo "$(YELLOW)🚀 Déploiement en cours...$(NC)"
	@./Backend/scripts/deploy.sh

update: ## Mettre à jour l'application
	@echo "$(YELLOW)🔄 Mise à jour en cours...$(NC)"
	@./Backend/scripts/update.sh

stop: ## Arrêter tous les services
	@echo "$(YELLOW)⏹️  Arrêt des services...$(NC)"
	@docker compose down
	@echo "$(GREEN)✅ Services arrêtés$(NC)"

restart: ## Redémarrer tous les services
	@echo "$(YELLOW)🔄 Redémarrage des services...$(NC)"
	@docker compose restart
	@echo "$(GREEN)✅ Services redémarrés$(NC)"

restart-backend: ## Redémarrer uniquement le backend
	@echo "$(YELLOW)🔄 Redémarrage du backend...$(NC)"
	@docker compose restart mahrasoft-backend
	@echo "$(GREEN)✅ Backend redémarré$(NC)"

restart-nginx: ## Redémarrer uniquement Nginx
	@echo "$(YELLOW)🔄 Redémarrage de Nginx...$(NC)"
	@docker compose restart nginx
	@echo "$(GREEN)✅ Nginx redémarré$(NC)"

logs: ## Voir tous les logs en temps réel
	@docker compose logs -f

logs-backend: ## Voir les logs du backend
	@docker compose logs -f mahrasoft-backend

logs-nginx: ## Voir les logs de Nginx
	@docker compose logs -f nginx

status: ## Voir le statut des services
	@echo "$(BLUE)📊 Statut des services:$(NC)"
	@docker compose ps
	@echo ""
	@echo "$(BLUE)💾 Utilisation des ressources:$(NC)"
	@docker stats --no-stream

health: ## Vérifier la santé du système
	@./Backend/scripts/check_health.sh

clean: ## Nettoyer les ressources Docker
	@echo "$(YELLOW)🧹 Nettoyage en cours...$(NC)"
	@docker system prune -f
	@echo "$(GREEN)✅ Nettoyage terminé$(NC)"

clean-all: ## Nettoyer complètement (attention!)
	@echo "$(RED)⚠️  Cela va supprimer tous les conteneurs, images et volumes!$(NC)"
	@read -p "Êtes-vous sûr ? [y/N] " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo ""; \
		docker compose down -v; \
		docker system prune -a --volumes -f; \
		echo "$(GREEN)✅ Nettoyage complet terminé$(NC)"; \
	else \
		echo ""; \
		echo "$(YELLOW)Annulé$(NC)"; \
	fi

backup: ## Créer un backup
	@echo "$(YELLOW)💾 Création du backup...$(NC)"
	@mkdir -p backups
	@tar -czf backups/backup-$(shell date +%Y%m%d-%H%M%S).tar.gz \
		Backend/ docker-compose.yml .env 2>/dev/null || true
	@echo "$(GREEN)✅ Backup créé dans backups/$(NC)"

build: ## Construire les images Docker
	@echo "$(YELLOW)🔨 Construction des images...$(NC)"
	@docker compose build --no-cache
	@echo "$(GREEN)✅ Images construites$(NC)"

up: ## Démarrer les services en arrière-plan
	@echo "$(YELLOW)▶️  Démarrage des services...$(NC)"
	@docker compose up -d
	@echo "$(GREEN)✅ Services démarrés$(NC)"

down: ## Arrêter et supprimer les conteneurs
	@echo "$(YELLOW)⏹️  Arrêt complet...$(NC)"
	@docker compose down
	@echo "$(GREEN)✅ Conteneurs supprimés$(NC)"

shell-backend: ## Accéder au shell du backend
	@docker compose exec mahrasoft-backend sh

shell-nginx: ## Accéder au shell de Nginx
	@docker compose exec nginx sh

test-health: ## Tester les endpoints de santé
	@echo "$(BLUE)🔍 Test des endpoints:$(NC)"
	@echo -n "Backend health: "
	@docker compose exec mahrasoft-backend curl -sf http://localhost:8000/health >/dev/null && echo "$(GREEN)✅ OK$(NC)" || echo "$(RED)❌ FAIL$(NC)"
	@echo -n "Backend ping:   "
	@docker compose exec mahrasoft-backend curl -sf http://localhost:8000/ping >/dev/null && echo "$(GREEN)✅ OK$(NC)" || echo "$(RED)❌ FAIL$(NC)"
	@echo -n "HTTP redirect:  "
	@curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "301\|302" && echo "$(GREEN)✅ OK$(NC)" || echo "$(RED)❌ FAIL$(NC)"
	@echo -n "HTTPS health:   "
	@curl -k -sf https://localhost/health >/dev/null && echo "$(GREEN)✅ OK$(NC)" || echo "$(RED)❌ FAIL$(NC)"

renew-ssl: ## Renouveler les certificats SSL
	@./Backend/scripts/renew_ssl.sh

dev: ## Mode développement (logs en direct)
	@docker compose up

prod: deploy ## Alias pour deploy

# Par défaut, afficher l'aide
.DEFAULT_GOAL := help
