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
