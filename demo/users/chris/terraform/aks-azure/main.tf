# Configure the Azure provider
variable "client_secret" {
  type = string
  description = "azure client secret for the appropriate service principle below"
  default = "abcde"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.48.0"
    }
  }

  required_version = ">= 1.1.0"
}

// Modules _must_ use remote state. The provider does not persist state.
// NOTE: This is for keeping state in CrossPlane in a K8s cluster.
terraform {
  backend "kubernetes" {
    secret_suffix     = "providerconfig-default"
    namespace         = "default"
    in_cluster_config = true
  }
}

provider "azurerm" {
  features {}
  client_id = "40872f6d-74b1-4f0c-a560-7d754d8fd3dd"
  tenant_id = "6cea5d02-bfe1-4887-89f4-1dae00a54c60"
  subscription_id = "b471e439-04ca-42fe-af9c-a2eedb46cdfa"
  client_secret = var.client_secret
}

resource "azurerm_resource_group" "rg" {
  name     = "RG-Chris-aks"
  location = "eastus"
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "example-aks1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "standard_d2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.example.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw

  sensitive = true
}

