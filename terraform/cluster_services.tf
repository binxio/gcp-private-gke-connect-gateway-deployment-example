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