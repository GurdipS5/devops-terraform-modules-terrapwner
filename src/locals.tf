locals {
  common_endpoints = {
    # Version Control
    "github" = {
      host = "github.com"
      port = 443
    }
    "gitlab" = {
      host = "gitlab.com"
      port = 443
    }
    "bitbucket" = {
      host = "bitbucket.org"
      port = 443
    }

    # Container Registries
    "docker" = {
      host = "docker.io"
      port = 443
    }
    "ghcr" = {
      host = "ghcr.io"
      port = 443
    }
    "quay" = {
      host = "quay.io"
      port = 443
    }

    # Cloud Providers
    "aws" = {
      host = "sts.amazonaws.com"
      port = 443
    }
    "azure" = {
      host = "management.azure.com"
      port = 443
    }
    "gcp" = {
      host = "cloudresourcemanager.googleapis.com"
      port = 443
    }

    # Monitoring & Observability
    "datadog" = {
      host = "api.datadoghq.com"
      port = 443
    }
    "newrelic" = {
      host = "api.newrelic.com"
      port = 443
    }
    "splunk" = {
      host = "api.splunk.com"
      port = 443
    }

    # Security & Compliance
    "snyk" = {
      host = "api.snyk.io"
      port = 443
    }
    "sonarqube" = {
      host = "sonarcloud.io"
      port = 443
    }
    "jfrog" = {
      host = "jfrog.io"
      port = 443
    }

    # CI/CD Platforms
    "circleci" = {
      host = "circleci.com"
      port = 443
    }
    "jenkins" = {
      host = "updates.jenkins.io"
      port = 443
    }
    "artifactory" = {
      host = "jfrog.com"
      port = 443
    }

    # Additional Security Tools
    "vault" = {
      host = "vault.example.com" # Replace with actual Vault endpoint
      port = 443
    }
    "harbor" = {
      host = "harbor.example.com" # Replace with actual Harbor endpoint
      port = 443
    }

    # Additional Cloud Services
    "aws_s3" = {
      host = "s3.amazonaws.com"
      port = 443
    }
    "aws_ecr" = {
      host = "ecr.amazonaws.com"
      port = 443
    }
    "azure_acr" = {
      host = "azurecr.io"
      port = 443
    }
    "gcp_gcr" = {
      host = "gcr.io"
      port = 443
    }

    # Additional Monitoring
    "grafana" = {
      host = "grafana.example.com" # Replace with actual Grafana endpoint
      port = 443
    }
    "prometheus" = {
      host = "prometheus.example.com" # Replace with actual Prometheus endpoint
      port = 443
    }
  }
}
