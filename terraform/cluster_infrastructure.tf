# GKE cluster fleet registration
resource "google_gke_hub_membership" "example" {
  project = var.project_id
  membership_id = "example"

  endpoint {
    gke_cluster {
     resource_link = google_container_cluster.example.id
    }
  }

  authority {
    issuer = "https://container.googleapis.com/v1/${google_container_cluster.example.id}"
  }
}

# GKE cluster
resource "google_service_account" "example" {
  project      = var.project_id
  account_id   = "example"
  display_name = "Service Account for Example cluster nodes"
}

resource "google_container_cluster" "example" {
  project  = var.project_id
  location = "europe-west4-a"
  name     = "example"

  network    = google_compute_network.example.name
  subnetwork = google_compute_subnetwork.example_nl_gke.name

  ip_allocation_policy {
    services_secondary_range_name = "example-nl-gke-services"
    cluster_secondary_range_name  = "example-nl-gke-pods"
  }

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "10.1.0.0/28"
  }

  master_authorized_networks_config {
    cidr_blocks {
      display_name = "management"
      cidr_block   = google_compute_subnetwork.example_nl_mgmt.ip_cidr_range
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  initial_node_count       = 1
  
  node_config {
    preemptible = true
    machine_type = "e2-medium"

    service_account = google_service_account.example.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}