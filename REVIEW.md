# Repository Review

**Scope:** Naming, repository structure, and documentation only. This review does not assess application behavior, security, or runtime configuration. No code or configuration files were changed.

## Summary

The repository has a simple, understandable top-level split between shared infrastructure (`_base/`) and media services (`dmc/`). The README provides a broad setup walkthrough, but it no longer consistently describes the files and services currently in the repository. Naming is also mixed between abbreviations, product names, and descriptive names.

## Findings

### Medium — README service list and directory tree are out of date

The README's service table omits **Wizarr** and **Jellystat**, although both are defined in `dmc/compose/docker-compose.yml` and have corresponding subdomain variables in `dmc/compose/.env`. The directory tree also does not show those services and presents the `dmc/services/` folders as though they are present, while they are ignored by `.gitignore` and only `.gitkeep` is tracked under `dmc/services/`.

**Recommendation:** Keep the service list and directory tree aligned with the Compose file and tracked repository contents. Explain that service configuration directories are generated locally and are not committed.

### Medium — Setup documentation refers to an environment template that does not exist

The README instructs users to copy `dmc/compose/.env.example` if it exists, but there is no `.env.example`; the tracked environment file is `dmc/compose/.env`. This conditional instruction is ambiguous and the sample values shown elsewhere do not fully match the actual environment file.

**Recommendation:** Document one clear setup path and make the sample environment variables match the actual variable names and values expected by the Compose file.

### Medium — Repository names for configuration and data are inconsistent

The base Compose environment uses `NETWORK_CONF_DIR` for Traefik configuration and `DATA_DIR` for Traefik data. The README describes a `dmc/services/` configuration tree, while the Compose file uses a `SERVICES_DIR` variable for service data. These names make it harder to distinguish application configuration, infrastructure configuration, and persistent data.

**Recommendation:** Use consistent, descriptive terms for configuration and persistent-data locations across the README, environment files, and directory descriptions.

### Low — Acronym and product-name capitalization varies

Names include `dmc`/“Download Media Center,” `Jellyseerr` in prose but `jellyseerr` in paths and variables, `JellyStat`/`jellystat`, and `Wizarr`/`wizarrrr` (the image name). Case variation in documentation is understandable for product names, but it makes references harder to scan and search.

**Recommendation:** Use canonical product spelling in prose and a consistent lowercase convention for paths, service keys, and environment variable suffixes.

### Low — The two top-level directory names are unclear

The top-level directories `_base/` and `dmc/` are not self-explanatory. `_base` is an abstract name, while `dmc` is an unexplained abbreviation in the path itself; readers must consult the README to learn what they contain.

**Recommendation:** Consider replacing them with descriptive names that communicate their roles, such as `infrastructure/` and `media-services/`.

### Low — Some README examples contain inconsistent or unfinished placeholders

Examples use differing domain placeholders (`your-domain`, `your_domain.ch`, and `your-domain.com`), include a doubled slash in a media path, and refer to an optional `.env.example` that is absent. The Quick Start directory tree and variable examples should also be checked against the actual repository layout.

**Recommendation:** Choose one placeholder convention (for example, `example.com`) and ensure paths and sample commands are internally consistent.

### Low — README could be shorter and more compact

The README repeats setup details across its Quick Start, configuration, service-specific, and maintenance sections. It currently contains no embedded images, which keeps it text-focused.

**Recommendation:** Condense repeated instructions into a shorter, more compact guide, linking to focused reference material if needed. Keep the README image-free.

### Low — The `dmc/network/` directory is unexplained

`dmc/network/` currently contains only `.gitkeep` and is not described in the README or represented in the Compose structure. Its purpose is not clear from the repository.

**Recommendation:** Briefly document its intended purpose, or omit it if it is not part of the intended project structure.

## Suggested documentation structure

1. State which services run in Docker and which are expected to run externally.
2. Document the actual top-level layout and distinguish tracked files from directories created during setup.
3. List all Compose services and their corresponding hostnames.
4. Provide one setup path using the environment file that exists in the repository.
5. Use one consistent naming and placeholder convention throughout.
