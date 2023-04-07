# Cloud Build triggers Terraform deployments
resource "google_service_account" "example_cloudbuild" {
  project      = var.project_id
  account_id   = "example-cloudbuild-sa"
  display_name = "Example CloudBuild deployments service"
}


# Grant permission to deploy to connected clusters
resource "google_project_iam_member" "project_gkehub_viewer_example_cloud" {
  project = var.project_id
  role = "roles/gkehub.viewer"
  member = "serviceAccount:${google_service_account.example_cloudbuild.email}"
}

resource "google_project_iam_member" "project_gateway_editor_example_cloudbuild" {
  project = var.project_id
  role = "roles/gkehub.gatewayEditor"
  member = "serviceAccount:${google_service_account.example_cloudbuild.email}"
}

resource "google_project_iam_member" "project_container_developer_example_cloudbuild" {
  project = var.project_id
  role = "roles/container.developer"
  member = "serviceAccount:${google_service_account.example_cloudbuild.email}"
}


resource "google_cloudbuild_trigger" "example_kubectl_deploy" {
  project = var.project_id
  location = "europe-west4"
  name     = "example-${random_id.example.hex}-kubectl-deploy"
  description = "Deploys to a private GKE cluster"

  service_account = google_service_account.example_cloudbuild.id

  source_to_build {
    repo_type = "CLOUD_SOURCE_REPOSITORIES"
    uri       = google_sourcerepo_repository.example.url
    ref       = "main"
  }

  build {
    source {
      repo_source {
        project_id = var.project_id
        repo_name = google_sourcerepo_repository.example.name
        branch_name = "main"
      }
    }

    options {
      logging = "CLOUD_LOGGING_ONLY"
    }

    step {
      name = "google/cloud-sdk:latest"
      entrypoint = "bash"
      args = [
        "-c",
        <<-EOT
        gcloud container fleet memberships get-credentials ${google_gke_hub_membership.example.name}
        
        kubectl run ubuntu --image ubuntu
        EOT
      ]
    }
  }
}

# Additional Cloud Build boilerplate..
resource "google_project_iam_member" "project_logs_writer_example_cloudbuild" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.example_cloudbuild.email}"
}

resource "google_sourcerepo_repository" "example" {
  project = var.project_id
  name    = "example-${random_id.example.hex}"
}

resource "google_sourcerepo_repository_iam_member" "example_source_reader_example_cloudbuild" {
  project = var.project_id
  repository = google_sourcerepo_repository.example.id
  role = "roles/source.reader"
  member = "serviceAccount:${google_service_account.example_cloudbuild.email}"
}