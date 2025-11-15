# 🚀 Mahrasoft.com - Déploiement Docker

Configuration de déploiement complète pour le site web **Mahrasoft.com** utilisant Docker, FastAPI, et Nginx avec SSL.

## 📋 Table des matières

- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration SSL](#configuration-ssl)
- [Déploiement](#déploiement)
- [Maintenance](#maintenance)
- [Commandes utiles](#commandes-utiles)
- [Dépannage](#dépannage)

## 🏗️ Architecture

```
mahrasoft.com/
├── docker-compose.yml          # Configuration Docker Compose
├── Makefile                    # Commandes simplifiées
├── .env.example                # Template variables d'environnement
├── .gitignore                  # Fichiers à ignorer
├── README.md                   # Ce fichier
│
├── Backend/
│   ├── app/                    # Application FastAPI
│   │   ├── main.py             # Point d'entrée
│   │   └── requirements.txt    # Dépendances Python
│   │
│   ├── build/                  # Configuration Docker
│   │   └── Dockerfile          # Image backend
│   │
│   ├── nginx/                  # Configuration Nginx
│   │   ├── nginx.conf          # Configuration principale
│   │   └── ssl/                # Certificats SSL
│   │
│   └── scripts/                # Scripts de déploiement
│       ├── deploy.sh           # Déploiement
│       ├── update.sh           # Mise à jour
│       ├── setup_ssl.sh        # Configuration SSL
│       └── check_health.sh     # Monitoring
│
└── logs/
    └── nginx/                  # Logs Nginx
```

### Stack technique

- **Backend**: FastAPI (Python 3.10)
- **Reverse Proxy**: Nginx (Alpine)
- **SSL**: Let's Encrypt / Auto-signé
- **Orchestration**: Docker Compose
- **OS**: Ubuntu 24

## 📦 Prérequis

- **Docker** (version 20.10+)
- **Docker Compose** (version 2.0+)
- **Git** (pour les mises à jour)
- **Certbot** (pour Let's Encrypt - optionnel)
- Nom de domaine configuré (pour production)

### Installation des prérequis

```bash
# Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# Installer Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Installer Docker Compose
sudo apt install docker-compose-plugin -y

# Installer Git
sudo apt install git -y

# Redémarrer la session pour appliquer les permissions Docker
newgrp docker
```

## 🔧 Installation

### 1. Cloner ou télécharger le projet

```bash
cd /opt
sudo mkdir mahrasoft.com
sudo chown $USER:$USER mahrasoft.com
cd mahrasoft.com

# Extraire l'archive ou cloner depuis Git
tar -xzf mahrasoft-deployment.tar.gz
# OU
# git clone <your-repo-url> .
```

### 2. Rendre les scripts exécutables

```bash
chmod +x Backend/scripts/*.sh
```

### 3. Configuration Optionnelle

```bash
# Copier le fichier d'exemple (si nécessaire)
cp .env.example .env

# Éditer les variables d'environnement
nano .env
```

## 🔐 Configuration SSL

Vous avez deux options pour les certificats SSL :

### Option 1: Certificat auto-signé (Développement/Test)

```bash
./Backend/scripts/setup_ssl.sh
# Choisir l'option 1
```

⚠️ **Attention**: Les navigateurs afficheront un avertissement de sécurité.

### Option 2: Let's Encrypt (Production - Recommandé)

```bash
./Backend/scripts/setup_ssl.sh
# Choisir l'option 2
# Entrer votre domaine et email
```

✅ Renouvellement automatique configuré via cron (tous les jours à 3h).

### Renouvellement manuel des certificats

```bash
./Backend/scripts/renew_ssl.sh
```

## 🚀 Déploiement

### Déploiement initial

```bash
# Option 1: Avec Make (recommandé)
make deploy

# Option 2: Avec le script directement
./Backend/scripts/deploy.sh
```

Le script va :
1. ✅ Vérifier les prérequis
2. ✅ Ajouter les endpoints /health et /ping si nécessaires
3. ✅ Vérifier les certificats SSL
4. ✅ Créer les dossiers nécessaires
5. ✅ Construire les images Docker
6. ✅ Démarrer les services
7. ✅ Effectuer les tests de santé

### Accéder au site

Une fois déployé, votre site est accessible sur :

- **HTTP**: http://mahrasoft.com (redirige vers HTTPS)
- **HTTPS**: https://mahrasoft.com
- **Health Check**: https://mahrasoft.com/health
- **Ping**: https://mahrasoft.com/ping
- **API Docs**: https://mahrasoft.com/docs

## 🔄 Maintenance

### Mise à jour de l'application

```bash
# Option 1: Avec Make
make update

# Option 2: Avec le script
./Backend/scripts/update.sh
```

Le script va :
1. Créer un backup de sécurité
2. Récupérer les dernières modifications Git
3. Reconstruire les images
4. Redémarrer les services

### Voir les logs

```bash
# Tous les logs
make logs

# Backend uniquement
make logs-backend

# Nginx uniquement
make logs-nginx

# Dernières 50 lignes
docker compose logs --tail=50 mahrasoft-backend
```

### Redémarrer les services

```bash
# Redémarrer tous les services
make restart

# Redémarrer un service spécifique
make restart-backend
make restart-nginx
```

### Arrêter les services

```bash
# Arrêter tous les services
make stop

# Arrêter et supprimer les volumes
docker compose down -v
```

## 📊 Commandes utiles

### Commandes Make

```bash
make help          # Afficher l'aide
make install       # Installer les prérequis
make ssl           # Configurer SSL
make deploy        # Déployer l'application
make update        # Mettre à jour
make logs          # Voir tous les logs
make status        # Statut des services
make health        # Check santé système
make restart       # Redémarrer
make stop          # Arrêter
make clean         # Nettoyer Docker
make backup        # Créer un backup
make test-health   # Tester les endpoints
```

### État des services

```bash
# Voir le statut
make status

# Statistiques en temps réel
docker stats

# Health check manuel
curl -k https://localhost/health
```

### Accéder aux conteneurs

```bash
# Backend
make shell-backend

# Nginx
make shell-nginx
```

### Nettoyage

```bash
# Nettoyer les ressources inutilisées
make clean

# Nettoyer tout (images, conteneurs, volumes)
make clean-all
```

### Backup manuel

```bash
# Créer un backup
make backup
```

## 🐛 Dépannage

### Le backend ne démarre pas

```bash
# Voir les logs détaillés
docker compose logs mahrasoft-backend

# Vérifier la configuration
docker compose config

# Reconstruire l'image
docker compose build --no-cache mahrasoft-backend
docker compose up -d mahrasoft-backend
```

### Nginx ne démarre pas

```bash
# Vérifier la syntaxe Nginx
docker compose exec nginx nginx -t

# Voir les logs
docker compose logs nginx

# Vérifier les certificats SSL
ls -lh Backend/nginx/ssl/
openssl x509 -in Backend/nginx/ssl/cert.pem -noout -dates
```

### Erreur de permission

```bash
# Corriger les permissions des dossiers
sudo chmod -R 755 /mnt/storage/docker/mahrasoft
sudo chown -R $USER:$USER logs/
chmod +x Backend/scripts/*.sh
```

### Port déjà utilisé

```bash
# Voir quel processus utilise le port 80
sudo lsof -i :80

# Voir quel processus utilise le port 443
sudo lsof -i :443

# Arrêter le processus conflictuel
sudo kill -9 <PID>
```

### Certificat SSL expiré

```bash
# Renouveler le certificat
./Backend/scripts/renew_ssl.sh

# Ou renouveler manuellement avec certbot
sudo certbot renew --standalone
```

### Health check échoue

```bash
# Vérifier que l'endpoint existe dans main.py
grep -n "health" Backend/app/main.py

# Tester directement le backend
docker compose exec mahrasoft-backend curl http://localhost:8000/health

# Vérifier les logs
docker compose logs --tail=50 mahrasoft-backend
```

## 🔒 Sécurité

### Bonnes pratiques

- ✅ Utiliser Let's Encrypt en production
- ✅ Garder Docker et les dépendances à jour
- ✅ Ne jamais commiter le fichier `.env`
- ✅ Utiliser des mots de passe forts
- ✅ Limiter les permissions des fichiers
- ✅ Sauvegarder régulièrement
- ✅ Monitorer les logs

### Firewall (UFW)

```bash
# Activer le firewall
sudo ufw enable

# Autoriser SSH
sudo ufw allow 22/tcp

# Autoriser HTTP et HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Vérifier le statut
sudo ufw status
```

## 📞 Support

Pour toute question ou problème :

- **Email**: contact@mahrasoft.com
- **Site**: https://mahrasoft.com

## 📝 Licence

© 2024 Mahrasoft Innovations SARL. Tous droits réservés.

---

**Dernière mise à jour**: Novembre 2024  
**Version**: 1.0.0
