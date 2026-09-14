# DevOps Intern Assessment

[![CI](https://github.com/MSCloudDev/devops-intern-final/actions/workflows/ci.yml/badge.svg)](https://github.com/MSCloudDev/devops-intern-final/actions/workflows/ci.yml)

**Name:** Mahmoud Shams
**Assessment date:** 2026-09-14

I used this repository to build and run a small NGINX app with Docker, GitHub Actions, Nomad, Consul, Promtail, Loki, and Grafana.


## Prerequisites

- Docker
- Nomad
- Consul
- ShellCheck
- Git

## Quick Start

```bash
git clone https://github.com/MSCloudDev/devops-intern-final.git
cd devops-intern-final
docker build --build-arg BUILD_SHA=local-test -t devops-project:test ./app
docker run --rm -d --name devops-project -p 8080:8080 devops-project:test
bash scripts/healthcheck.sh http://localhost:8080/healthz
docker compose -f monitoring/docker-compose.yaml up -d
```

The app runs at http://localhost:8080. Grafana runs at http://localhost:3000.

## Task 1: Source Control

I worked in feature branches and merged the changes into `main`. The final state is tagged `v1.0.0`:

```bash
git checkout main
git pull --ff-only
git show --no-patch --decorate v1.0.0
```

The history includes feature, fix, and docs commits, plus merged pull requests.

## Task 2: Linux Scripts

Both scripts use `set -euo pipefail` and are executable in Git.

```bash
shellcheck scripts/*.sh
bash scripts/sysinfo.sh
bash scripts/healthcheck.sh http://localhost:8080/healthz
```

Example health check output:

```text
Health check OK: http://localhost:8080/healthz returned HTTP 200
```

`sysinfo.sh` prints basic host information and Docker status.

## Task 3: Containerisation

The image uses `nginx:1.27-alpine`, listens on port 8080, runs as `nginx`, and has a Docker health check. The build SHA is written into the page.

```bash
docker build --build-arg BUILD_SHA=local-test -t devops-project:test ./app
docker run --rm -d --name devops-project -p 8080:8080 devops-project:test
curl -i http://localhost:8080/
curl -i http://localhost:8080/healthz
docker images devops-project:test
```

Observed locally on 2026-09-14:

```text
HTTP/1.1 200 OK
Build SHA: local-test
HTTP/1.1 200 OK
OK
Image size: 20,980,771 bytes (about 20.9 MB)
```

## Task 4: Continuous Integration

The workflow runs on pushes and pull requests to `main`.

- `lint` runs ShellCheck and Hadolint.
- `build` builds the image with the Git commit SHA.
- `test` starts the image and runs `scripts/healthcheck.sh`.
- `publish` runs only after a push to `main` and pushes both the SHA tag and `latest` to GHCR.

Only the publish job gets `packages: write` permission.

## Task 5: Nomad

Start local Nomad and Consul dev agents, then run:

```bash
nomad job validate -var="image_tag=latest" nomad/nginx-app.nomad.hcl
nomad job plan -var="image_tag=latest" nomad/nginx-app.nomad.hcl
nomad job run -var="image_tag=latest" nomad/nginx-app.nomad.hcl
nomad job status nginx-app
```

The job has one group and one Docker task. It uses 100 MHz CPU, 64 MB memory, a dynamic `http` port, a Consul HTTP check, rolling updates, restart, and reschedule settings.

I validated this with Nomad 2.0.6. A running allocation needs a Linux Nomad client with the Docker driver. The native Windows client did not support the Linux Docker driver.

Observed in WSL2 on 2026-09-14:

```text
nomad job plan: All tasks successfully allocated
nomad job run: Job registration successful
Allocation: df158fd4-c41b-ba43-730c-8580fa652c9f
Status: running
Dynamic port: 31787 -> 8080
HTTP /healthz: 200 OK
Consul nginx-health: passing (HTTP GET /healthz: 200 OK)
```

## Task 6: Loki Monitoring

Start Loki, Promtail, and Grafana:

```bash
docker compose -f monitoring/docker-compose.yaml up -d
curl -i http://localhost:8080/missing-page
```

In Grafana, add Loki with URL `http://loki:3100`. In Explore, use:

```logql
{job="docker", service="nginx-app"} |~ " 404 | 500 "
```

For the application log stream, Promtail adds the `job`, `container`, and `service` labels. More notes are in [monitoring/loki_setup.md](monitoring/loki_setup.md).

![Grafana Explore](docs/screenshots/grafana-explore.png)

## Troubleshooting

1. **Port 8080 is already in use:** stop the old container with `docker rm -f devops-project`, or use another host port such as `-p 8081:8080`.
2. **The page shows `BUILD_SHA_PLACEHOLDER`:** rebuild the image with `--build-arg BUILD_SHA=...`; the value is inserted during `docker build`.
3. **Nomad allocation is unhealthy:** check `nomad alloc status <allocation-id>` and confirm that the allocated port reaches `/healthz` and that Consul is running.

## Limitations

- GHCR publishing needs package write access for `GITHUB_TOKEN`.
- Promtail uses Docker discovery. A Nomad client logging setup would be better for a larger deployment.
- TLS, secrets management, persistent Grafana settings, and high availability are not included.
