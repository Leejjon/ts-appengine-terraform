terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
  backend "gcs" {
    # Can't use the variable that contains the bucket name here.
    bucket = "ts-appengine-terraform-tfstate"
    prefix = "ts-appengine-terraform/state"
  }
}

provider "google" {
  project = var.project_name
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

#resource "google_app_engine_application" "ts-appengine-app" {
#  project     = "node-on-gcp-terraform"
#  location_id = "us-central"
#}
