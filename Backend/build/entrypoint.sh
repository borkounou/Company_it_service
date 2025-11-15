#!/bin/bash

set -eu

# Couleurs pour les logs
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

# ==========================================
# VÉRIFICATION DES VARIABLES D'ENVIRONNEMENT
# ==========================================
log_info "🔍 Checking environment variables..."

# Variables optionnelles mais recommandées
if [ -z "${SECRET_KEY:-}" ]; then
  log_warn "⚠️  SECRET_KEY environment variable is not set (will use default)"
fi

log_info "✅ Environment variables checked"

# ==========================================
# CRÉATION DES RÉPERTOIRES
# ==========================================
log_info "📁 Creating necessary directories..."

# Répertoires pour les uploads et fichiers statiques
UPLOAD_DIRS=(
  "/mahrasoft-app/uploads/images"
  "/mahrasoft-app/uploads/documents"
  "/mahrasoft-app/uploads/media"
  "/mahrasoft-app/uploads/temp"
  "/mahrasoft-app/static/css"
  "/mahrasoft-app/static/js"
  "/mahrasoft-app/static/lib"
  "/mahrasoft-app/static/img"
  "/mahrasoft-app/logs"
)

for dir in "${UPLOAD_DIRS[@]}"; do
  mkdir -p "$dir"
  log_debug "Created: $dir"
done

# Permissions
if [ "${APP_DEBUG:-False}" == "True" ]; then
  log_warn "⚠️  Setting permissive permissions (DEBUG mode)"
  chmod -R 777 /mahrasoft-app/uploads /mahrasoft-app/static 2>/dev/null || true
else
  log_info "✅ Using secure permissions (PRODUCTION mode)"
  chmod -R 755 /mahrasoft-app/uploads /mahrasoft-app/static 2>/dev/null || true
fi

log_info "✅ Directories created"

# ==========================================
# VÉRIFICATION DU FICHIER MAIN.PY
# ==========================================
log_info "🔍 Checking application files..."

if [ ! -f "/mahrasoft-app/main.py" ]; then
  log_error "❌ main.py not found in /mahrasoft-app"
  log_error "📂 Current directory contents:"
  ls -la /mahrasoft-app
  exit 1
fi

log_info "✅ Application files found"

# ==========================================
# CONFIGURATION DE L'APPLICATION
# ==========================================
log_info "⚙️  Configuring application..."

# Afficher les informations de configuration
log_info "Configuration:"
log_info "  - Environment: ${ENVIRONMENT:-production}"
log_info "  - Debug mode: ${APP_DEBUG:-False}"
log_info "  - Workers: ${NB_WORKERS:-2}"
log_info "  - Python path: ${PYTHONPATH:-/mahrasoft-app}"

# Options de démarrage basées sur le mode
if [ "${APP_DEBUG:-False}" == "True" ]; then
  RELOAD_OPT="--reload"
  LOG_LEVEL="debug"
  log_warn "🚧 Running in DEBUG mode with auto-reload enabled"
else
  RELOAD_OPT=""
  LOG_LEVEL="info"
  log_info "🚀 Running in PRODUCTION mode"
fi

# ==========================================
# COLLECTE DES FICHIERS STATIQUES (Optionnel)
# ==========================================
# Si vous avez un script pour collecter les fichiers statiques
# log_info "📦 Collecting static files..."
# python -c "from static_collector import collect; collect()" || log_warn "⚠️  Static collection failed"

# ==========================================
# VÉRIFICATION DE SANTÉ DE L'APPLICATION
# ==========================================
log_info "🏥 Performing health checks..."

# Vérifier que Python peut importer l'application
if python -c "import main" 2>/dev/null; then
  log_info "✅ Application imports successfully"
else
  log_error "❌ Failed to import application"
  log_error "Python import error:"
  python -c "import main" || true
  exit 1
fi

# ==========================================
# LANCEMENT DE L'APPLICATION
# ==========================================
log_info "🚀 Starting Mahrasoft.com application..."
log_info "🌐 Server will be available at http://0.0.0.0:8000"
log_info "📊 Running with ${NB_WORKERS:-2} workers"

# Changer le répertoire de travail
cd /mahrasoft-app

# Lancer Gunicorn avec Uvicorn workers
exec gunicorn \
  --workers ${NB_WORKERS:-2} \
  --worker-class uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8000 \
  --timeout 120 \
  --keep-alive 5 \
  --log-level ${LOG_LEVEL} \
  --access-logfile /mahrasoft-app/logs/access.log \
  --error-logfile /mahrasoft-app/logs/error.log \
  --capture-output \
  --enable-stdio-inheritance \
  ${RELOAD_OPT} \
  main:app
