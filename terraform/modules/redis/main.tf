terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_managed_redis" "redis" {
  name                      = "redis-${var.owner}-bilan"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  sku_name                  = "Balanced_B0"
  public_network_access     = "Disabled"
  high_availability_enabled = false

  default_database {
    clustering_policy = "NoCluster"
  }

  tags = var.tags
}