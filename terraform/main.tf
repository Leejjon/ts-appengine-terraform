terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
  backend "gcs" {
    bucket = "ts-appengine-terraform-tfstate"
    prefix = "ts-appengine-terraform/state"
  }
}

provider "google" {
  project = "node-on-gcp-terraform"
  region  = "us-central1"
}

resource "google_storage_bucket" "terraform_state" {
  name          = "ts-appengine-terraform-tfstate"
  force_destroy = false
  location      = "US"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}
