terraform {
  required_version = "~> 1.2.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.59"
    }

    random = {
      source = "hashicorp/random"
      version = "~> 3.4"
    }
  }
}

provider "google" {
}
