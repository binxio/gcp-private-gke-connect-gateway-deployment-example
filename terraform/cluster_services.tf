resource "kubernetes_pod" "nginx" {
  metadata {
    namespace = "default"
    name = "nginx"
  }

  spec {
    container {
      name  = "nginx"
      image = "nginx:latest"
    }
  }
}