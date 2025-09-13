#!/bin/bash

# Jellyfin Ecosystem Kit Setup Script
# This script helps you set up the entire Jellyfin ecosystem

set -e

echo "🚀 Jellyfin Ecosystem Kit Setup"
echo "================================"
echo

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"

# Create global network if it doesn't exist
if ! docker network ls | grep -q "global"; then
    echo "📡 Creating global Docker network..."
    docker network create global
    echo "✅ Global network created"
else
    echo "✅ Global network already exists"
fi

# Check if .env file exists
ENV_FILE="dmc/compose/.env"
if [[ ! -f "$ENV_FILE" ]]; then
    echo "❌ Environment file not found at $ENV_FILE"
    echo "Please configure your environment variables first."
    echo "See the README.md for configuration details."
    exit 1
fi

echo "✅ Environment file found"

# Source the .env file to get variables
source "$ENV_FILE"

# Create required directories
echo "📁 Creating required directories..."

# Create media directories
sudo mkdir -p "$MOVIES_DIR" || { echo "Failed to create movies directory. Please check permissions."; exit 1; }
sudo mkdir -p "$TV_SHOWS_DIR" || { echo "Failed to create TV shows directory. Please check permissions."; exit 1; }
sudo mkdir -p "$DOWNLOAD_DIR" || { echo "Failed to create download directory. Please check permissions."; exit 1; }

# Create service config directories
mkdir -p dmc/services/{transmission,radarr,sonarr,prowlarr,jellyseerr}

echo "✅ Directories created"

# Set proper permissions
echo "🔑 Setting permissions..."
sudo chown -R "$ENV_PUID:$ENV_PGID" "$MOVIES_DIR" "$TV_SHOWS_DIR" "$DOWNLOAD_DIR" 2>/dev/null || true
chown -R "$ENV_PUID:$ENV_PGID" dmc/services/ 2>/dev/null || true

echo "✅ Permissions set"

# Check if Traefik config needs updating
TRAEFIK_CONFIG="_base/traefik/traefik.toml"
if grep -q "admin@domain.com" "$TRAEFIK_CONFIG"; then
    echo "⚠️  Warning: Please update the email address in $TRAEFIK_CONFIG"
    echo "   Change 'admin@domain.com' to your actual email address"
fi

# Check if Jellyfin config needs updating
JELLYFIN_CONFIG="_base/traefik/jellyfin.yml"
if grep -q "higitv.ch" "$JELLYFIN_CONFIG" || grep -q "192.168.1.96" "$JELLYFIN_CONFIG"; then
    echo "⚠️  Warning: Please update the Jellyfin configuration in $JELLYFIN_CONFIG"
    echo "   - Update the domain from 'higitv.ch' to your domain"
    echo "   - Update the server IP from '192.168.1.96' to your Jellyfin server IP"
fi

echo
echo "🎬 Ready to start services!"
echo "=========================="
echo
echo "1. Start Traefik (reverse proxy):"
echo "   cd _base/compose && docker-compose up -d"
echo
echo "2. Start media services:"
echo "   cd ../../dmc/compose && docker-compose up -d"
echo
echo "3. Access your services at:"
echo "   - Traefik Dashboard: https://$DOMAIN/dashboard/"
echo "   - Transmission: https://transmission.$DOMAIN"
echo "   - Radarr: https://radarr.$DOMAIN"
echo "   - Sonarr: https://sonarr.$DOMAIN"
echo "   - Prowlarr: https://prowlarr.$DOMAIN"
echo "   - Jellyseerr: https://jellyseerr.$DOMAIN"
echo
echo "📖 For detailed setup instructions, see README.md"
echo
read -p "Start services now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Starting Traefik..."
    cd _base/compose
    docker-compose up -d
    
    echo "🚀 Starting media services..."
    cd ../../dmc/compose
    docker-compose up -d
    
    echo
    echo "✅ All services started!"
    echo "📊 Check status with: docker-compose ps"
    echo "📋 View logs with: docker-compose logs -f"
else
    echo "Services not started. Run the commands manually when ready."
fi
