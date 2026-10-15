variable "image_repository" {
  type    = string
  default = "ghcr.io/msclouddev/devops-intern-final"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

job "nginx-app" {
  datacenters = ["dc1"]
  type        = "service"

  update {
    max_parallel     = 1
    min_healthy_time = "10s"
    healthy_deadline = "2m"
    auto_revert      = true
  }

  group "nginx-app" {
    count = 1

    network {
      port "http" {
        to = 8080
      }

      port "metrics" {
        to = 9113
      }
    }

    restart {
      attempts = 3
      interval = "30m"
      delay    = "15s"
      mode     = "delay"
    }

    reschedule {
      attempts       = 5
      unlimited      = false
      interval       = "30m"
      delay          = "30s"
      delay_function = "exponential"
      max_delay      = "5m"
    }

    task "nginx-app" {
      driver = "docker"

      config {
        image = "${var.image_repository}:${var.image_tag}"
        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 64
      }

      service {
        name = "nginx-app"
        port = "http"

        check {
          name     = "nginx-app-healthz"
          type     = "http"
          path     = "/healthz"
          interval = "10s"
          timeout  = "2s"
        }
      }

    }

    task "nginx-exporter" {
      driver = "docker"

      config {
        image = "nginx/nginx-prometheus-exporter:1.4.2"
        args  = ["--nginx.scrape-uri=http://127.0.0.1:8080/nginx_status"]
        ports = ["metrics"]
      }

      lifecycle {
        hook    = "prestart"
        sidecar = true
      }

      resources {
        cpu    = 50
        memory = 32
      }

      service {
        name = "nginx-app-metrics"
        port = "metrics"

        check {
          name     = "nginx-app-metrics-healthz"
          type     = "http"
          path     = "/metrics"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}