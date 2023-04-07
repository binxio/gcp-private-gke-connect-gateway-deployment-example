terraform {
  required_version = "~> 1.2.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.59"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.19"
    }
  }
}

provider "google" {
}

provider "kubernetes" {
  host = "https://connectgateway.googleapis.com/v1/projects/${data.google_project.project.number}/locations/global/gkeMemberships/${google_gke_hub_membership.example.membership_id}"

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "gke-gcloud-auth-plugin"
  }
}
