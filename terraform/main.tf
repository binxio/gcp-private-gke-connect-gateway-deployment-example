data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_service" "connectgateway" {
  project = var.project_id
  service = "connectgateway.googleapis.com"

  disable_on_destroy = false
}


# Minimal VPC
resource "google_compute_network" "example" {
  project = var.project_id
  name    = "example"

  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "example_nl_mgmt" {
  project = var.project_id
  network = google_compute_network.example.id
  region  = "europe-west4"
  name    = "example-nl-mgmt"

  ip_cidr_range = "10.0.0.0/24"

  private_ip_google_access = true
}

resource "google_compute_subnetwork" "example_nl_gke" {
  project = var.project_id
  network = google_compute_network.example.id
  region  = "europe-west4"
  name    = "example-nl-gke"

  ip_cidr_range = "10.0.1.0/24"

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "example-nl-gke-services"
    ip_cidr_range = "10.10.0.0/24"
  }

  secondary_ip_range {
    range_name    = "example-nl-gke-pods"
    ip_cidr_range = "10.20.0.0/22"
  }
}
