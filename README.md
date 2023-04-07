# Private GKE deployments using Connect Gateway

This example shows how to use Connect Gateway to deploy Kubernetes resources to a private GKE cluster - a cluster without a public API IP address.

## Connect Gateway

The [Connect Gateway](https://cloud.google.com/anthos/multicluster-management/gateway) uses [fleets](https://cloud.google.com/anthos/multicluster-management/fleet-overview) to let you connect and interact with Kubernetes clusters in a simple, consistent and secured way. The Connect Gateway leverages the fleet membership intricacies to connect to the Kubernetes cluster for you.

For GKE in particular, Connect Gateway is able to connect to your Kubernetes cluster without any additional infrastructure such as bastion hosts, network peering or proxy deployments.

**Remark** Although Connect Gateway is powerfull, it does not [support](https://cloud.google.com/anthos/multicluster-management/gateway/using#run_commands_against_the_cluster) the following kubectl commands: `exec`, `proxy`, `attach` and `port-forward`.


## Terraform integration

This repository includes a [Terraform configuration](./terraform/) that deploys a private GKE cluster with an Ubuntu pod. The Ubuntu pod is deployed using the Connect Gateway API:

```hcl
provider "kubernetes" {
  host = "https://connectgateway.googleapis.com/v1/projects/${data.google_project.project.number}/locations/global/gkeMemberships/${google_gke_hub_membership.example.membership_id}"

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "gke-gcloud-auth-plugin"
  }
}
```

Note that the Connect Gateway API endpoint refers to a Fleet membership. This membership is defined as:

```hcl
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
```

## Cloud Build integration

This repository includes a [Cloud Build configuration](./cloudbuild/) that deploys a Cloud Build trigger (and depending infrastructure) to deploy an Ubuntu pod. The Ubuntu pod is deployed using `kubectl` and the Connect Gateway API:

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

Note that the Cloud Build Trigger needs the following permissions to be able to deploy Kubernetes resources.

```hcl
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
```

> Sadly these permissions can't (yet?) be configured at the Connect Gateway (GKE Hub Membership) level.