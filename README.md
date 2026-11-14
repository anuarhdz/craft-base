# craft-base

Shared Docker base image for Craft CMS: PHP-FPM + nginx
([serversideup/php](https://serversideup.net/open-source/docker-php/)) with
Craft's extensions and a MySQL client. The same image runs locally (instead of
DDEV) and in production on devpush.

```
ghcr.io/anuarhdz/craft-base:php8.5        # rolling, rebuilt weekly
ghcr.io/anuarhdz/craft-base:php8.5-YYYYMMDD   # pinned
ghcr.io/anuarhdz/craft-base:php8.4
```

Platforms: `linux/amd64`, `linux/arm64`.

## What the image adds

- PHP extensions `bcmath exif gd intl` (on top of upstream's `pdo_mysql`,
  `pdo_pgsql`, `zip`, `redis`, …)
- `mysqldump`/`mysql` wrapped with `--skip-ssl` (Debian ships MariaDB clients,
  which reject MySQL 8's self-signed cert; Craft backups and `craft up` need them)
- nginx webroot `/var/www/html/web`, port 8080, runs as `www-data`
- `storage/`, `web/cpresources`, `web/uploads` owned by `www-data` so named
  volumes mount writable
- `CRAFT_COMPOSER_AUTOINSTALL=true` (set by `compose.dev.yml`) runs
  `composer install` on boot when `vendor/` is missing

## Use it in a Craft project

Copy from `template/`:

| File | Into the project as |
| --- | --- |
| `Dockerfile` | `Dockerfile` (stages `dev`, `assets`, `prod`) |
| `compose.yml` | `compose.yml` — production, what devpush runs |
| `compose.dev.yml` | `compose.dev.yml` — local |
| `dockerignore` | `.dockerignore` |
| `env.example.dev` | `.env` (fill `CRAFT_SECURITY_KEY`) |
| `config/app.php` | `config/app.php` — SMTP from env (Mailpit in dev) |
| `vite.config.ts` | merge into yours (Vite projects only) |

For Vite projects, also use `config/vite.php` from craft-chalupa: it reads all
`VITE_*` variables and uses `checkDevServer` in dev.

### Local development

```bash
cp env.example.dev .env
echo "CRAFT_SECURITY_KEY=$(openssl rand -hex 32)" >> .env   # or edit the line
docker compose up -d                 # web, db, mailpit
docker compose exec web php craft install
```

| URL | |
| --- | --- |
| http://localhost:8080 | site (`/admin` for the CP) |
| http://localhost:8025 | Mailpit |
| `localhost:3306` | MySQL `craft` / `craft` |

**With Vite (HMR):** `docker compose --profile vite up -d`, or set
`COMPOSE_PROFILES=vite` in `.env`. Craft pings the dev server and uses it when
it is up.

**Without Vite:** build once and Craft serves `web/dist` from the manifest:

```bash
docker compose run --rm vite npm run build
```

Projects with no frontend build: drop the `assets` stage and its `COPY --from`
in the Dockerfile, the `vite` service and the `VITE_*` variables.

Everyday commands:

```bash
docker compose exec web php craft <command>
docker compose exec web composer require <package>
docker compose exec db mysql -ucraft -pcraft craft
docker compose down        # keep data
docker compose down -v     # wipe DB
```

Running several projects at once: change `WEB_PORT`, `VITE_PORT`, `DB_PORT`,
`MAILPIT_PORT` and `COMPOSE_PROJECT_NAME` in `.env`.

Linux hosts: set `USER_ID`/`GROUP_ID` (`id -u`/`id -g`) in `.env` so files
created by the container stay yours. macOS needs nothing.

### Production (devpush)

`compose.yml` builds the last stage (`prod`): vendor and assets baked in, OPcache
on, separate `queue` worker. Follow the `devpush-craft` skill from step 5.

Run the production stack locally to check a build:

```bash
docker compose -f compose.yml -p prodtest --env-file /path/to/prod.env up -d --build
```

## Publishing

`.github/workflows/publish.yml` builds both PHP versions for amd64 + arm64 on
every push to `main`, weekly, and on demand.

**After the first publish, make the package public** (GitHub → Packages →
`craft-base` → Package settings → Change visibility). devpush builds projects
on the server, which must pull the base image without credentials. The image
holds no secrets.

Local build: `docker build -t ghcr.io/anuarhdz/craft-base:php8.5 .`
(`--build-arg PHP_VERSION=8.4` for 8.4).
