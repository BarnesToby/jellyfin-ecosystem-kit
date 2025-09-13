# Jellyfin Ecosystem Kit

A complete Docker-based media server ecosystem using Jellyfin with automated content management through the *arr suite (Sonarr, Radarr, Prowlarr), Transmission for downloads, Jellyseerr for requests, and Traefik as a reverse proxy.

## 🏗️ Architecture Overview

This project consists of two main components:

- **`_base/`**: Core infrastructure with Traefik reverse proxy
- **`dmc/`**: Download Media Center with all media management services

## 📋 Services Included

| Service | Purpose | Default Port | Web Interface |
|---------|---------|--------------|---------------|
| **Traefik** | Reverse proxy & SSL termination | 80/443 | `https://your-domain/dashboard/` |
| **Jellyfin** | Media server (external setup) | 8096 | `https://higitv.ch` |
| **Transmission** | BitTorrent client | 9091 | `https://transmission.your-domain` |
| **Radarr** | Movie management | 7878 | `https://radarr.your-domain` |
| **Sonarr** | TV show management | 8989 | `https://sonarr.your-domain` |
| **Prowlarr** | Indexer manager | 9696 | `https://prowlarr.your-domain` |
| **Jellyseerr** | Media request system | 5055 | `https://jellyseerr.your-domain` |

## 🚀 Quick Start Guide

### Prerequisites

- Docker and Docker Compose installed
- Domain name with DNS pointing to your server
- Jellyfin server running separately (see [Jellyfin Setup](#jellyfin-setup))

### Step 1: Configure Domain Settings

Edit the environment file to set your domain and paths:

```bash
cd dmc/compose
cp .env.example .env  # If .env.example exists, otherwise edit existing .env
nano .env
```

Configure the following variables in `dmc/compose/.env`:

```env
# Domain Configuration
DOMAIN=your-domain.com

# Subdomain Configuration
SUB_DOMAIN_TRANSMISSION=transmission
SUB_DOMAIN_SONARR=sonarr
SUB_DOMAIN_RADARR=radarr
SUB_DOMAIN_PROWLARR=prowlarr
SUB_DOMAIN_JELLYSEERR=jellyseerr

# Storage Paths (adjust to your setup)
MOVIES_DIR=/location/to/media/directory//movies
TV_SHOWS_DIR=/location/to/media/directory//tvshows
MEDIA_DIR=/location/to/media/directory/
DOWNLOAD_DIR=/mnt/media-download
SERVICES_DIR=../services

# User Configuration
ENV_PUID=1000  # Run `id` command to get your user ID
ENV_PGID=1000  # Run `id` command to get your group ID

# Timezone
TIMEZONE=Europe/Zurich  # Set your timezone
```

### Step 2: Setup Jellyfin (External)

Jellyfin runs separately from this ecosystem. Install and configure it:

1. **Install Jellyfin on your server:**
   ```bash
   # For Ubuntu/Debian
   curl https://repo.jellyfin.org/install-debuntu.sh | sudo bash
   ```

2. **Configure Jellyfin routing in Traefik:**
   
   Edit `_base/traefik/jellyfin.yml`:
   ```yaml
   http:
     routers:
       dmc-jellyfin:
         rule: "Host(`your-domain.com`)"  # Change from higitv.ch
         entryPoints:
           - web
           - websecure
         service: dmc-jellyfin
         tls:
           certResolver: letsencrypt
         # Uncomment for basic auth protection:
         # middlewares:
         #   - dmc-auth

     services:
       dmc-jellyfin:
         loadBalancer:
           servers:
             - url: "http://YOUR_JELLYFIN_SERVER_IP:8096"  # Update this IP
   ```

### Step 3: Create Required Directories

```bash
# Create directory structure
sudo mkdir -p /location/to/media/directory//{movies,tvshows}
sudo mkdir -p /mnt/media-download
sudo mkdir -p ./dmc/services/{transmission,radarr,sonarr,prowlarr,jellyseerr}

# Set proper permissions
sudo chown -R 1000:1000 /location/to/media/directory/
sudo chown -R 1000:1000 /mnt/media-download
sudo chown -R 1000:1000 ./dmc/services
```

### Step 4: Configure Traefik

Update the Traefik configuration with your email for SSL certificates:

Edit `_base/traefik/traefik.toml`:
```toml
[certificatesResolvers.letsencrypt.acme]
  email = "your-email@domain.com"  # Change this
  storage = "acme.json"
  [certificatesResolvers.letsencrypt.acme.httpChallenge]
    entryPoint = "web"
```

### Step 5: Create Docker Network

```bash
docker network create global
```

### Step 6: Start the Services

1. **Start the base infrastructure (Traefik):**
   ```bash
   cd _base/compose
   docker-compose up -d
   ```

2. **Start the media services:**
   ```bash
   cd ../../dmc/compose
   docker-compose up -d
   ```

### Step 7: Initial Configuration

1. **Access services and complete setup:**
   - Visit each service URL and complete the initial setup wizard
   - Configure download paths, quality profiles, and indexers

2. **Configure service integration:**
   - Add Prowlarr indexers to Radarr and Sonarr
   - Set up Transmission as download client in Radarr/Sonarr
   - Connect Jellyseerr to Jellyfin, Radarr, and Sonarr

## 🔧 Configuration Details

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DOMAIN` | Your main domain | `example.com` |
| `SUB_DOMAIN_*` | Subdomain for each service | `movies`, `tv`, etc. |
| `MOVIES_DIR` | Movies storage path | `/mnt/storage/movies` |
| `TV_SHOWS_DIR` | TV shows storage path | `/mnt/storage/tvshows` |
| `DOWNLOAD_DIR` | Downloads temporary path | `/mnt/downloads` |
| `SERVICES_DIR` | Config storage path | `../services` |
| `ENV_PUID` | User ID for file permissions | `1000` |
| `ENV_PGID` | Group ID for file permissions | `1000` |
| `TIMEZONE` | Server timezone | `America/New_York` |

### Directory Structure

```
jellyfin-ecosystem-kit/
├── _base/                          # Core infrastructure
│   ├── compose/
│   │   └── docker-compose.yml      # Traefik service
│   └── traefik/
│       ├── traefik.toml            # Traefik main config
│       ├── jellyfin.yml            # Jellyfin routing config
│       └── .htpasswd               # Basic auth credentials
├── dmc/                            # Download Media Center
│   ├── compose/
│   │   ├── docker-compose.yml      # All media services
│   │   └── .env                    # Environment configuration
│   └── services/                   # Service configurations
│       ├── transmission/
│       ├── radarr/
│       ├── sonarr/
│       ├── prowlarr/
│       └── jellyseerr/
```

## 🔒 Security

### Basic Authentication

The setup includes basic authentication for sensitive services. To create/update credentials:

```bash
# Install htpasswd utility
sudo apt-get install apache2-utils

# Create new user
htpasswd -c _base/traefik/.htpasswd username

# Add additional users
htpasswd _base/traefik/.htpasswd another_user
```

### SSL Certificates

Traefik automatically handles SSL certificates via Let's Encrypt using HTTP challenge. Ensure:
- Ports 80 and 443 are open and forwarded to your server
- DNS A records point to your server's public IP

## 🐛 Troubleshooting

### Common Issues

1. **Services not accessible:**
   - Check if the `global` Docker network exists: `docker network ls`
   - Verify DNS resolution: `nslookup your-domain.com`
   - Check firewall settings

2. **SSL certificate issues:**
   - Verify email in `traefik.toml`
   - Check Traefik logs: `docker logs dmc_traefik_1`
   - Ensure ports 80/443 are accessible from internet

3. **Permission errors:**
   - Check PUID/PGID in `.env` match your user: `id`
   - Verify directory ownership: `ls -la /mnt/`

4. **Download issues:**
   - Check Transmission configuration
   - Verify download paths are accessible by all services
   - Check indexer configuration in Prowlarr

### Useful Commands

```bash
# View all container logs
docker-compose logs -f

# Restart all services
docker-compose restart

# Check container status
docker-compose ps

# Update containers
docker-compose pull && docker-compose up -d

# Clean up unused resources
docker system prune -a
```

## 📚 Service-Specific Configuration

### Transmission
- **Web UI:** `https://transmission.your-domain.com`
- **Download path:** Set to `/downloads` (mapped to `DOWNLOAD_DIR`)
- **Incomplete directory:** `/downloads/incomplete`

### Radarr
- **Web UI:** `https://radarr.your-domain.com`
- **Movies path:** `/movies` (mapped to `MOVIES_DIR`)
- **Download client:** Add Transmission at `transmission:9091`

### Sonarr
- **Web UI:** `https://sonarr.your-domain.com`
- **TV path:** `/tv` (mapped to `TV_SHOWS_DIR`)
- **Download client:** Add Transmission at `transmission:9091`

### Prowlarr
- **Web UI:** `https://prowlarr.your-domain.com`
- **Sync apps:** Add Radarr and Sonarr using internal container names

### Jellyseerr
- **Web UI:** `https://jellyseerr.your-domain.com`
- **Jellyfin URL:** `http://YOUR_JELLYFIN_IP:8096`
- **Radarr/Sonarr:** Use internal container names and ports

## 🔄 Maintenance

### Regular Tasks

1. **Monitor disk space** for download and media directories
2. **Update containers** monthly: `docker-compose pull && docker-compose up -d`
3. **Backup configurations** from `services/` directory
4. **Review logs** for any errors or issues

### Backup Strategy

```bash
# Backup all service configurations
tar -czf jellyfin-ecosystem-backup-$(date +%Y%m%d).tar.gz dmc/services/

# Backup Traefik configuration
tar -czf traefik-backup-$(date +%Y%m%d).tar.gz _base/traefik/
```

## 📄 License

This project is licensed under the terms specified in the LICENSE file.