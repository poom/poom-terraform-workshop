terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.42.0"
    }
  }

  required_version = ">= 0.13.4"
}

// Configure the Google Cloud provider
provider "google" {
  credentials = file("poom-terraform-workshop.json")
  project     = "poom-terraform-workshop"
  region      = "asia-southeast1"

  version = "~> 3.42.0"
}

provider "random" {
  version = "~> 3.0.0"
}

// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
  byte_length = 8
}

// A single Compute Engine instance
resource "google_compute_instance" "default" {
  name         = "flask-vm-${random_id.instance_id.hex}"
  machine_type = "f1-micro"
  zone         = "asia-southeast1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  // Make sure flask is installed on all new instances for later steps
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; pip install flask"

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  metadata = {
    ssh-keys = "poom:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "google_compute_firewall" "default" {
  name    = "flask-app-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }
}
