terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
  }
  backend "gcs" {
    bucket = "tfstate-project-3111890e-6ba4-4e0e-95f"
    prefix = "practica-2"
  }
}

provider "google" {
  project = var.proyecto
  region  = "us-central1"
  zone    = var.zona
}

resource "google_compute_firewall" "permitir_http" {
  name    = "permitir-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["servidor-web"]
}

resource "google_compute_instance" "web" {
  name         = "web-tf"
  machine_type = var.tipo_maquina
  tags         = ["servidor-web"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = file("arranque.sh")
  allow_stopping_for_update = true
}

resource "google_compute_address" "ip_estatica" {
  name = "ip-web-estatica"
  region = "us-central1"
}

network_interface {
  network = "default"
  access_config {
    nat_ip = google_compute_address.ip_estatica.address
  }
}