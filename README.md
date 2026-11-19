# Jellyfin Ecosystem Kit

A Docker Compose setup for media management and access, with Jellyfin expected to run separately (for example, directly on the host).

## What runs where

| Service | Runs in | Purpose | Hostname (replace `example.com`) |
|---|---|---|---|
| Traefik | Docker | Reverse proxy and TLS | Routes the services listed below |
| Transmission | Docker | Downloads | `https://transmission.example.com` |
| Radarr | Docker | Movie management | `https://radarr.example.com` |
| Sonarr | Docker | TV management | `https://sonarr.example.com` |
| Prowlarr | Docker | Indexer management | `https://prowlarr.example.com` |
| Jellyseerr | Docker | Media requests | `https://jellyseerr.example.com` |
| Wizarr | Docker | User invitations | `https://wizarr.example.com` |
| Jellystat | Docker, with PostgreSQL | Jellyfin statistics | `https://stats.example.com` |
| Jellyfin | External | Media server | `https://example.com` |

Jellyfin is routed by Traefik but is not defined in Compose. Set DNS records for the hostnames above to your server, and forward ports 80 and 443 to it.

## Repository layout

```text
infrastructure/
├── compose/                 # Traefik Compose file and environment
└── traefik/                 # Traefik and external Jellyfin routing config
media-services/
├── compose/                 # Media services Compose file and environment
├── network/                 # Reserved; currently unused by Compose
└── services/                # Generated service data; local and uncommitted
```

The `services/` directories are created locally by setup and hold persistent application data. Their contents are ignored by Git; only the directory placeholder is tracked. The `infrastructure/compose/.env` and `media-services/compose/.env` files are the environment files used by this repository.

## Setup

1. Install Docker with the Compose plugin. Point your DNS records at the server and make ports 80 and 443 reachable.
2. Edit `media-services/compose/.env`. Set `DOMAIN`, media/download paths, `SERVICE_DATA_DIR` if needed, your `TIMEZONE` and user/group IDs, and replace both Jellystat placeholder secrets with strong random values. Its default media paths are `/mnt/media/...`; `SERVICE_DATA_DIR=../services` is relative to `media-services/compose/`.
3. Edit `infrastructure/compose/.env` if you want to change the default Traefik config/data paths. Update `infrastructure/traefik/traefik.toml` with your ACME email and `infrastructure/traefik/jellyfin.yml` with the Jellyfin hostname and server IP.
4. Create the external Docker network and local data directories:

   ```sh
   docker network create global
   mkdir -p /mnt/media/movies /mnt/media/tvshows /mnt/downloads
   mkdir -p media-services/services/{transmission,radarr,sonarr,prowlarr,jellyseerr,wizarr,jellystat}
   ```

   Adjust ownership and permissions so the configured `ENV_PUID` and `ENV_PGID` can access the media, download, and service-data directories.
5. Start Traefik, then the media services:

   ```sh
   cd infrastructure/compose && docker compose up -d
   cd ../../media-services/compose && docker compose up -d
   ```

   Alternatively, `./setup.sh` checks prerequisites, creates the network and directories, and offers to start both Compose projects.
6. Finish each service's initial setup in its web UI. Connect Prowlarr to Radarr and Sonarr, configure Transmission as their download client, and connect Jellyseerr and Jellystat to your Jellyfin server.

## Environment variables

The media environment file defines these values (see that file for the full list of subdomain variables):

| Variable | Meaning |
|---|---|
| `DOMAIN` | Base domain used for service hostnames |
| `SUB_DOMAIN_*` | Lowercase hostname prefix for each service |
| `MOVIES_DIR`, `TV_SHOWS_DIR`, `DOWNLOAD_DIR` | Host paths mounted into media services |
| `SERVICE_DATA_DIR` | Host path for persistent service configuration and data |
| `ENV_PUID`, `ENV_PGID` | User and group IDs used by supported containers |
| `TIMEZONE` | Container timezone |
| `JELLYSTAT_POSTGRES_PASSWORD`, `JELLYSTAT_JWT_SECRET` | Jellystat database and token secrets |

The infrastructure environment uses `TRAEFIK_CONFIG_DIR` for Traefik configuration and `TRAEFIK_DATA_DIR` for its persistent data. Both Compose projects mount the external `global` Docker network.

## Maintenance

Run Compose commands from the relevant `infrastructure/compose/` or `media-services/compose/` directory:

```sh
docker compose ps
docker compose logs -f
docker compose pull && docker compose up -d
```

Back up `media-services/services/` and `infrastructure/traefik/` (including `acme.json` if present) to preserve application and proxy state.

## License

See [LICENSE](LICENSE).
