# Loki Monitoring Setup

## Components

- Loki 3.0.0 stores the log streams.
- Promtail 3.0.0 discovers Docker containers and reads their JSON logs.
- Grafana 11.1.0 provides the Explore view.

## Start the stack

Run this from the repository root:

```bash
docker compose -f monitoring/docker-compose.yaml up -d
docker compose -f monitoring/docker-compose.yaml ps
```

Grafana is available at `http://localhost:3000`. Add a Loki data source with the URL `http://loki:3100`.

## Labels

Promtail attaches these labels to Docker log streams:

- `job`: `docker`
- `container`: the Docker container name
- `service`: `nginx-app`

The Docker socket is used for discovery and the container JSON log directory is mounted read-only.

## Check ingestion

Start the application and create a known 404 entry:

```bash
docker run --rm --name devops-project -p 8080:8080 devops-project:test
curl -i http://localhost:8080/not-found
```

In Grafana Explore, select the Loki data source and run:

```logql
{job="docker", service="nginx-app"}
```

To isolate failed requests:

```logql
{job="docker", service="nginx-app"} |~ " 404 | 500 "
```

The expected result is an NGINX access log containing `/not-found` and status `404`. If no stream appears, restart Promtail after confirming that Docker exposes JSON logs and check `docker compose -f monitoring/docker-compose.yaml logs promtail`.

Observed locally on 2026-09-14:

```text
container=devops-project job=docker service=nginx-app
172.17.0.1 - - [14/Sep/2026:14:02:05 +0000] "GET /not-found HTTP/1.1" 404 153
```

## Notes

The configuration files are committed in this directory so the stack does not depend on configuration downloaded at runtime. Grafana dashboards and authentication are intentionally left as local-development defaults.