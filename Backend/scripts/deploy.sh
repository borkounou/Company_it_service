#!/bin/bash

set -e

echo "🚀 Déploiement de Mahrasoft.com"
echo "================================"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Vérifications préalables
log_info "Vérification de l'environnement..."

# Docker
if ! command -v docker &> /dev/null; then
    log_error "Docker n'est pas installé"
    exit 1
fi

# Docker Compose
if ! command -v docker compose &> /dev/null; then
    log_error "Docker Compose n'est pas installé"
    exit 1
fi

# Fichier .env (optionnel pour ce projet)
if [ ! -f ".env" ]; then
    log_warn "Le fichier .env n'existe pas (optionnel)"
    log_info "Vous pouvez créer un fichier .env si nécessaire"
fi

# Vérifier que l'endpoint /health existe
log_info "Vérification de l'endpoint /health dans main.py..."
if [ ! -f "Backend/app/main.py" ]; then
    log_error "Le fichier Backend/app/main.py n'existe pas"
    exit 1
fi

if ! grep -q "@app.get(\"/health\")" Backend/app/main.py && ! grep -q "@app.get('/health')" Backend/app/main.py; then
    log_warn "L'endpoint /health n'existe pas dans main.py"
    echo ""
    echo "Voulez-vous que je l'ajoute automatiquement ? (Y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]] || [[ -z "$response" ]]; then
        log_info "Ajout des endpoints /health et /ping..."
        
        # Créer un backup
        cp Backend/app/main.py Backend/app/main.py.backup
        
        # Ajouter les endpoints
        cat >> Backend/app/main.py << 'EOF'

# ================================
# Health Check Endpoints
# ================================
from datetime import datetime

@app.get("/health")
async def health_check():
    """Endpoint de santé pour Docker health check et monitoring"""
    return {
        "status": "healthy",
        "service": "Mahrasoft.com",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0"
    }

@app.get("/ping")
async def ping():
    """Simple ping endpoint pour vérifier que le service répond"""
    return {
        "status": "ok",
        "message": "pong",
        "timestamp": datetime.now().isoformat()
    }
EOF
        
        log_info "✅ Endpoints /health et /ping ajoutés avec succès"
        log_info "📁 Backup sauvegardé: Backend/app/main.py.backup"
    else
        log_warn "Continuons sans ajouter les endpoints..."
    fi
fi

# Certificats SSL
if [ ! -f "Backend/nginx/ssl/cert.pem" ] || [ ! -f "Backend/nginx/ssl/key.pem" ]; then
    log_warn "Certificats SSL non trouvés"
    read -p "Voulez-vous les générer maintenant ? (Y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        chmod +x Backend/scripts/setup_ssl.sh
        ./Backend/scripts/setup_ssl.sh
    else
        log_error "Les certificats SSL sont nécessaires pour le déploiement"
        exit 1
    fi
fi

# Créer les dossiers nécessaires
log_info "Création des dossiers nécessaires..."
mkdir -p logs/nginx
mkdir -p /mnt/storage/docker/mahrasoft/uploads
mkdir -p /mnt/storage/docker/mahrasoft/static
mkdir -p Backend/nginx/ssl

# Définir les permissions
log_info "Configuration des permissions..."
chmod -R 755 /mnt/storage/docker/mahrasoft
chmod -R 755 logs

# Arrêter les conteneurs existants
log_info "Arrêt des conteneurs existants..."
docker compose down 2>/dev/null || true

# Nettoyer les images non utilisées
log_info "Nettoyage des images Docker..."
docker system prune -f

# Construire les images
log_info "Construction des images Docker..."
docker compose build --no-cache

# Démarrer le backend
log_info "Démarrage du backend FastAPI..."
docker compose up -d mahrasoft-backend

# Attendre que le backend soit prêt
log_info "Attente du démarrage du backend..."
timeout=60
counter=0
until docker compose exec mahrasoft-backend curl -sf http://localhost:8000/health > /dev/null 2>&1; do
    counter=$((counter + 1))
    if [ $counter -gt $timeout ]; then
        log_error "Timeout: Le backend ne démarre pas correctement"
        log_error "Logs du backend:"
        docker compose logs mahrasoft-backend
        exit 1
    fi
    echo -n "."
    sleep 2
done
echo ""
log_info "✅ Backend démarré avec succès"

# Démarrer Nginx
log_info "Démarrage de Nginx..."
docker compose up -d nginx

# Attendre que Nginx soit prêt
sleep 5

# Vérifier le statut des services
log_info "Vérification du statut des services..."
docker compose ps

echo ""
log_info "Tests de connectivité..."

# Test HTTP (doit rediriger vers HTTPS)
if curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null | grep -q "301\|302"; then
    log_info "✅ HTTP → HTTPS redirect fonctionne"
else
    log_warn "⚠️  Problème avec la redirection HTTP"
fi

# Test HTTPS
if curl -k -s -o /dev/null -w "%{http_code}" https://localhost/health 2>/dev/null | grep -q "200"; then
    log_info "✅ HTTPS fonctionne correctement"
else
    log_warn "⚠️  Problème avec HTTPS"
fi

# Afficher les logs récents
echo ""
log_info "Derniers logs du backend:"
docker compose logs --tail=20 mahrasoft-backend

echo ""
log_info "Derniers logs de Nginx:"
docker compose logs --tail=10 nginx

echo ""
echo "========================================="
log_info "✅ Déploiement terminé avec succès !"
echo "========================================="
echo ""
echo "🌐 URLs d'accès :"
echo "   - HTTP:  http://mahrasoft.com (redirige vers HTTPS)"
echo "   - HTTPS: https://mahrasoft.com"
echo "   - IP:    https://$(hostname -I | awk '{print $1}')"
echo ""
echo "🔍 Health checks:"
echo "   - Health: https://mahrasoft.com/health"
echo "   - Ping:   https://mahrasoft.com/ping"
echo ""
echo "📊 Commandes utiles:"
echo "   - Logs en temps réel:   docker compose logs -f"
echo "   - Logs backend:         docker compose logs -f mahrasoft-backend"
echo "   - Logs nginx:           docker compose logs -f nginx"
echo "   - Arrêter:              docker compose down"
echo "   - Redémarrer:           docker compose restart"
echo "   - Statut:               docker compose ps"
echo "   - Stats:                docker stats"
echo "   - Test health:          curl -k https://localhost/health"
echo "   - Mise à jour:          ./Backend/scripts/update.sh"
echo ""
log_info "🎉 Votre site web Mahrasoft.com est maintenant en ligne !"
echo ""
