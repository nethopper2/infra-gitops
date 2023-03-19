# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
  client_id = "40872f6d-74b1-4f0c-a560-7d754d8fd3dd"
  tenant_id = "6cea5d02-bfe1-4887-89f4-1dae00a54c60"
  subscription_id = "b471e439-04ca-42fe-af9c-a2eedb46cdfa"
}

resource "azurerm_resource_group" "rg" {
  name     = "myTFResourceGroupChris"
  location = "westus2"
}
