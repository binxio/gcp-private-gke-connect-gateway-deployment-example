# Cloud Build Connect Gateway Example

This example deploys a private GKE cluster and a Cloud Build trigger that deploys Kubernetes resources to it.

## Cloud Build

Simple deployment using `kubectl`:

```hcl
resource "google_cloudbuild_trigger" "example_kubectl_deploy" {
  ...
  description = "Deploys to a private GKE cluster"

  build {
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

    ...
  }
}
```

A Terraform-based deployment needs a custom image with both `gcloud` and `Terraform` installed. See [this image as an example](https://github.com/GoogleCloudPlatform/cloud-builders-community/tree/master/terraform). Use the the [Terraform example](../terraform/) to configure your deployment.

```hcl
provider "kubernetes" {
  host = "https://connectgateway.googleapis.com/v1/projects/${data.google_project.project.number}/locations/global/gkeMemberships/${google_gke_hub_membership.example.membership_id}"

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "gke-gcloud-auth-plugin"

    # Optionally use service account impersonation..
    # args        = ["--impersonate_service_account", "my-service-account"]
  }
}

resource "kubernetes_pod" "ubuntu" {
  metadata {
    namespace = "default"
    name = "ubuntu"
  }

  spec {
    container {
      name  = "ubuntu"
      image = "ubuntu:latest"
    }
  }
}
```