#!/bin/bash

# Script de renouvellement SSL pour Mahrasoft.com
set -e

echo "🔄 Renouvellement des certificats SSL..."
echo "========================================"

# Arrêter Nginx
echo "⏸️  Arrêt de Nginx..."
cd /home/ubuntu/Company_it_service
docker compose stop nginx

# Renouveler les certificats
echo "🔐 Renouvellement avec Let's Encrypt..."
if sudo certbot renew --standalone; then
    echo "✅ Certificats renouvelés"
    
    # Copier les nouveaux certificats
    echo "📋 Copie des nouveaux certificats..."
    sudo cp /etc/letsencrypt/live/mahrasoft.com/fullchain.pem Backend/nginx/ssl/cert.pem
    sudo cp /etc/letsencrypt/live/mahrasoft.com/privkey.pem Backend/nginx/ssl/key.pem
    sudo chown ubuntu:ubuntu Backend/nginx/ssl/*.pem
    sudo chmod 644 Backend/nginx/ssl/cert.pem
    sudo chmod 600 Backend/nginx/ssl/key.pem
    
    # Redémarrer Nginx
    echo "▶️  Redémarrage de Nginx..."
    docker compose start nginx
    
    echo "✅ Renouvellement terminé avec succès !"
    echo "📅 Prochain renouvellement: $(sudo certbot certificates | grep 'Expiry Date')"
else
    echo "❌ Échec du renouvellement"
    docker compose start nginx
    exit 1
fi
