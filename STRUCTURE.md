# 📁 Structure du Projet Mahrasoft.com

Voici l'organisation complète de votre projet de déploiement Docker.

## 🌳 Arborescence

```
mahrasoft.com/
│
├── 📄 docker-compose.yml           # Configuration Docker Compose (racine)
├── 📄 Makefile                     # Commandes simplifiées
├── 📄 .env.example                 # Exemple de variables d'environnement
├── 📄 .env                         # Variables d'environnement (à créer)
├── 📄 .gitignore                   # Fichiers à ignorer par Git
├── 📄 README.md                    # Documentation principale
├── 📄 QUICK_START.md               # Guide de démarrage rapide
├── 📄 STRUCTURE.md                 # Ce fichier
│
├── 📁 Backend/                     # Dossier principal du backend
│   │
│   ├── 📁 app/                     # Application FastAPI
│   │   ├── 📄 main.py              # Point d'entrée FastAPI
│   │   ├── 📄 requirements.txt     # Dépendances Python
│   │   ├── 📁 static/              # Fichiers statiques (CSS, JS, images)
│   │   └── 📁 uploads/             # Fichiers uploadés
│   │
│   ├── 📁 build/                   # Configuration Docker
│   │   └── 📄 Dockerfile           # Image Docker backend
│   │
│   ├── 📁 nginx/                   # Configuration Nginx
│   │   ├── 📄 nginx.conf           # Configuration principale Nginx
│   │   └── 📁 ssl/                 # Certificats SSL
│   │       ├── 🔒 cert.pem         # Certificat SSL (à générer)
│   │       ├── 🔒 key.pem          # Clé privée SSL (à générer)
│   │       └── 📄 README.md        # Guide SSL
│   │
│   └── 📁 scripts/                 # Scripts de déploiement
│       ├── 🔧 deploy.sh            # Script de déploiement initial
│       ├── 🔧 update.sh            # Script de mise à jour
│       ├── 🔧 setup_ssl.sh         # Configuration des certificats SSL
│       ├── 🔧 renew_ssl.sh         # Renouvellement SSL (généré automatiquement)
│       └── 🔧 check_health.sh      # Script de monitoring
│
├── 📁 logs/                        # Logs de l'application
│   └── 📁 nginx/                   # Logs Nginx
│       ├── 📄 access.log
│       ├── 📄 error.log
│       └── 📄 ssl_renewal.log
│
└── 📁 backups/                     # Sauvegardes (créé automatiquement)
    └── 📄 backup-YYYYMMDD-HHMMSS.tar.gz
```

## 📋 Description des Fichiers Principaux

### Configuration Docker (Racine)

| Fichier | Description |
|---------|-------------|
| `docker-compose.yml` | Orchestre les services (backend + nginx) |
| `Makefile` | Commandes simplifiées (make deploy, make logs, etc.) |
| `.env.example` | Template des variables d'environnement |
| `.gitignore` | Fichiers à ne pas versionner |

### Backend/app/ - Application FastAPI

| Fichier | Description |
|---------|-------------|
| `main.py` | Application FastAPI avec endpoints essentiels |
| `requirements.txt` | Dépendances Python nécessaires |
| `static/` | Fichiers statiques (CSS, JS, images) |
| `uploads/` | Fichiers uploadés par les utilisateurs |

### Backend/build/ - Configuration Docker

| Fichier | Description |
|---------|-------------|
| `Dockerfile` | Image Docker pour FastAPI (Python Alpine) |

### Backend/nginx/ - Reverse Proxy

| Fichier | Description |
|---------|-------------|
| `nginx.conf` | Configuration complète avec SSL, proxy, CORS |
| `ssl/cert.pem` | Certificat SSL (Let's Encrypt ou auto-signé) |
| `ssl/key.pem` | Clé privée SSL |
| `ssl/README.md` | Guide pour les certificats SSL |

### Backend/scripts/ - Scripts de Déploiement

| Script | Objectif |
|--------|----------|
| `deploy.sh` | Déploiement complet de l'application |
| `update.sh` | Mise à jour avec Git pull + rebuild |
| `setup_ssl.sh` | Configuration SSL (auto-signé ou Let's Encrypt) |
| `renew_ssl.sh` | Renouvellement automatique des certificats |
| `check_health.sh` | Vérification de la santé du système |

### Documentation (Racine)

| Fichier | Contenu |
|---------|---------|
| `README.md` | Guide complet d'installation et d'utilisation |
| `QUICK_START.md` | Démarrage en 5 étapes |
| `STRUCTURE.md` | Ce fichier - structure du projet |

## 🚀 Flux de Déploiement

```
1. Installation des prérequis
   └── make install

2. Configuration SSL
   └── ./Backend/scripts/setup_ssl.sh
       ├── Option 1: Certificat auto-signé (dev)
       └── Option 2: Let's Encrypt (production)

3. Déploiement
   └── make deploy (ou ./Backend/scripts/deploy.sh)
       ├── Vérifications pré-déploiement
       ├── Construction des images Docker
       ├── Démarrage du backend
       ├── Démarrage de Nginx
       └── Tests de santé

4. Maintenance
   ├── make update      # Mise à jour depuis Git
   ├── make health      # Vérification santé
   ├── make logs        # Voir les logs
   └── make backup      # Créer un backup
```

## 🔄 Cycle de Mise à Jour

```
Code modifié → Git commit → Git push
                    ↓
            Sur le serveur:
                    ↓
            make update
                    ↓
      ┌─────────────────────────┐
      │ 1. Backup automatique   │
      │ 2. Git pull             │
      │ 3. Docker rebuild       │
      │ 4. Redémarrage services │
      │ 5. Tests de santé       │
      └─────────────────────────┘
                    ↓
          Application mise à jour
```

## 📦 Dépendances du Système

### Requis
- Docker (20.10+)
- Docker Compose (2.0+)
- Git

### Optionnel
- Certbot (pour Let's Encrypt)
- Make (pour les commandes simplifiées)

## 🔒 Fichiers Sensibles (.gitignore)

Ces fichiers ne doivent **JAMAIS** être versionnés:

- `.env` - Variables d'environnement
- `Backend/nginx/ssl/*.pem` - Certificats SSL
- `logs/` - Fichiers de logs
- `backups/` - Sauvegardes
- `Backend/app/uploads/` - Fichiers uploadés
- `*.backup` - Backups temporaires

## 📊 Volumes Docker

Les volumes persistants sont montés depuis:

```
/mnt/storage/docker/mahrasoft/
├── uploads/     → /app/uploads (backend)
│                → /var/www/mahrasoft/uploads (nginx)
│
└── static/      → /app/static (backend)
                 → /var/www/mahrasoft/static (nginx)
```

## 🌐 Ports Exposés

| Service | Port | Protocole |
|---------|------|-----------|
| Nginx | 80 | HTTP (redirect vers HTTPS) |
| Nginx | 443 | HTTPS |
| Backend | 8000 | HTTP (interne) |

## 🔍 Endpoints Disponibles

| URL | Description |
|-----|-------------|
| `/` | Page d'accueil API |
| `/health` | Health check (monitoring) |
| `/ping` | Test de connectivité |
| `/docs` | Documentation Swagger |
| `/redoc` | Documentation ReDoc |
| `/api/info` | Informations de l'API |
| `/api/services` | Liste des services |
| `/api/contact` | Formulaire de contact |

## 💡 Commandes Makefile Utiles

```bash
make help          # Afficher l'aide
make install       # Installer les prérequis
make ssl           # Configurer SSL (appelle Backend/scripts/setup_ssl.sh)
make deploy        # Déployer (appelle Backend/scripts/deploy.sh)
make update        # Mettre à jour (appelle Backend/scripts/update.sh)
make logs          # Voir tous les logs
make logs-backend  # Logs du backend
make logs-nginx    # Logs de Nginx
make status        # Statut des services
make health        # Check santé (appelle Backend/scripts/check_health.sh)
make restart       # Redémarrer tous les services
make stop          # Arrêter tous les services
make clean         # Nettoyer Docker
make backup        # Créer un backup
make test-health   # Tester les endpoints
```

## 📈 Monitoring

Le script `Backend/scripts/check_health.sh` vérifie:

1. ✅ Statut des services Docker
2. ✅ Endpoints de santé (/health, /ping)
3. ✅ Redirection HTTP → HTTPS
4. ✅ Validité des certificats SSL
5. ✅ Espace disque
6. ✅ Logs d'erreurs
7. ✅ Utilisation CPU/Mémoire

## 🔐 Sécurité

### Certificats SSL
- **Dev**: Auto-signé (365 jours)
- **Prod**: Let's Encrypt (90 jours, renouvellement auto)

### Headers de Sécurité (Nginx)
- Strict-Transport-Security (HSTS)
- X-Frame-Options
- X-Content-Type-Options
- X-XSS-Protection
- Referrer-Policy
- Permissions-Policy

### Configuration SSL
- TLS 1.2 et 1.3 uniquement
- Ciphers modernes et sécurisés
- OCSP Stapling activé

## 🗂️ Organisation vs Mahrasoftacademia

Cette structure suit le même pattern que mahrasoftacademia.com mais **sans base de données**:

```
mahrasoft.com (ce projet)     mahrasoftacademia.com
├── docker-compose.yml        ├── docker-compose.yml
└── Backend/                  └── Backend/
    ├── app/                      ├── app/
    ├── build/                    ├── build/
    ├── nginx/                    ├── nginx/
    └── scripts/                  └── scripts/
                                  (+ service PostgreSQL)
```

## 📞 Support

Pour toute question:
- Email: contact@mahrasoft.com
- Site: https://mahrasoft.com

---

**Mahrasoft Innovations SARL** - N'Djamena, Chad  
Version: 1.0.0 | Novembre 2024
