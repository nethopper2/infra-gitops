# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


provider "google" {
  project = var.project_id
  region  = var.region
  credentials = gcp-creds.ini
}

// Modules _must_ use remote state. The provider does not persist state.
terraform {
  backend "kubernetes" {
    secret_suffix     = "providerconfig-default"
    namespace         = "default"
    in_cluster_config = true
  }
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "chris-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "chris-subnet"
  region        = us-central1
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}
