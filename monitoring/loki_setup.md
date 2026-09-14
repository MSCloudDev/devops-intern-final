# Loki Setup

## Components

- Loki 3.0.0 stores logs.
- Promtail 3.0.0 reads Docker JSON logs.
- Grafana 11.1.0 is used to search them.

## Start

Run from the repository root:

```bash
docker compose -f monitoring/docker-compose.yaml up -d
docker compose -f monitoring/docker-compose.yaml ps
```

Open Grafana at `http://localhost:3000` and add Loki with the URL `http://loki:3100`.

## Labels

For the application log stream, Promtail adds these labels:

- `job`: `docker`
- `container`: the Docker container name
- `service`: `nginx-app`

Promtail uses the Docker socket and the read-only container log directory.

## Test logs

Start the app and create a 404 entry:

```bash
docker run --rm --name devops-project -p 8080:8080 devops-project:test
curl -i http://localhost:8080/not-found
```

In Grafana Explore, run:

```logql
{job="docker", service="nginx-app"}
```

To isolate failed requests:

```logql
{job="docker", service="nginx-app"} |~ " 404 | 500 "
```

The result should contain `/not-found` and status `404`. If no log appears, check `docker compose -f monitoring/docker-compose.yaml logs promtail`.

Observed locally on 2026-09-14:

```text
container=devops-project job=docker service=nginx-app
172.17.0.1 - - [14/Sep/2026:14:02:05 +0000] "GET /not-found HTTP/1.1" 404 153
```

## Notes

The config files are committed in this directory. Grafana uses its local default settings.