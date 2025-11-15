# Utiliser Python Alpine pour une image plus légère
FROM python:3.10-alpine

# Définir les variables d'environnement
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONPATH=/mahrasoft-app

# Installer les dépendances système nécessaires
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    curl \
    bash \
    && rm -rf /var/cache/apk/*

# Créer le répertoire de travail
WORKDIR /mahrasoft-app

# Copier requirements.txt depuis le dossier app
COPY app/requirements.txt .

# Installer les dépendances Python
RUN pip3 install --no-cache-dir -r requirements.txt

# Copier tout le contenu du dossier app
COPY app/ .

# Copier l'entrypoint
COPY build/entrypoint.sh /mahrasoft-app/entrypoint.sh

# Créer les dossiers nécessaires
RUN mkdir -p /mahrasoft-app/uploads \
             /mahrasoft-app/static \
             /mahrasoft-app/logs && \
    chmod -R 755 /mahrasoft-app && \
    chmod +x /mahrasoft-app/entrypoint.sh

# Exposer le port
EXPOSE 8000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Utiliser l'entrypoint
ENTRYPOINT ["/mahrasoft-app/entrypoint.sh"]
