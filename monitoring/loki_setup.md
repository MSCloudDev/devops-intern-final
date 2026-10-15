# Loki and Promtail

I use the committed `docker-compose.yaml`, `loki-config.yaml`, and `promtail-config.yaml` rather than downloading configuration at runtime.

## Start the stack

```sh
docker compose -f monitoring/docker-compose.yaml up -d
docker compose -f monitoring/docker-compose.yaml ps
curl http://localhost:3100/ready
```

Promtail reads Docker metadata through `/var/run/docker.sock`. It adds `job=docker`, the container name, the Compose service name, and a Nomad job label when that label exists. The NGINX container writes access logs to stdout, so Docker captures them for Promtail.

## Queries

After requesting a missing page, I use these LogQL queries in Grafana Explore:

```logql
{job="docker", service="nginx-app"}
{job="docker", service="nginx-app"} |= " 404 "
```

```sh
curl http://localhost:8080/does-not-exist
```

Observed locally on 2026-10-15: the query returned one stream with labels `container=devops-intern-final-nginx-app-1`, `job=docker`, and `service=nginx-app`. The returned line was:

```text
GET /does-not-exist HTTP/1.1" 404
```

The complete Grafana screenshot is still **Blocked — requires manual capture** because the integrated browser could not save the full scrollable dashboard canvas as one image.