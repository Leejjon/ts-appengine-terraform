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

resource "google_app_engine_application" "ts-appengine-app" {
  project     = var.project_name
  location_id = "us-central"
}

resource "google_storage_bucket" "app" {
  name          = "${var.project_name}-${random_id.app.hex}"
  location      = "US"
  force_destroy = true
  versioning {
    enabled = true
  }
}

resource "random_id" "app" {
  byte_length = 8
}

data "archive_file" "function_dist" {
  type        = "zip"
  source_dir  = "../app"
  output_path = "../app/app.zip"
}

resource "google_storage_bucket_object" "app" {
  name   = "app.zip"
  source = data.archive_file.function_dist.output_path
  bucket = google_storage_bucket.app.name
}

resource "google_app_engine_application_url_dispatch_rules" "ts-appengine-app-dispatch-rules" {
  dispatch_rules {
    domain = "*"
    path = "/*"
    service = "default"
  }
}

//https://github.com/Ipsossiapi/pt_streams/blob/2b09f2eb013d1902ca5ae63a9644ee2544f93596/terraform/appengine.tf
resource "google_app_engine_standard_app_version" "latest_version" {

  version_id = var.deployment_version
  service    = "default"
  runtime    = "nodejs20"

  entrypoint {
    shell = "node index.js"
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.app.name}/${google_storage_bucket_object.app.name}"
    }
  }

  instance_class = "F1"

  automatic_scaling {
    max_concurrent_requests = 10
    min_idle_instances      = 1
    max_idle_instances      = 3
    min_pending_latency     = "1s"
    max_pending_latency     = "5s"
    standard_scheduler_settings {
      target_cpu_utilization        = 0.5
      target_throughput_utilization = 0.75
      min_instances                 = 0
      max_instances                 = 4
    }
  }
  noop_on_destroy = true
  delete_service_on_destroy = true
}
