terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                = "psql-${var.owner}-bilan"
  resource_group_name = var.resource_group_name
  location            = var.location

  version                       = "16"
  administrator_login           = var.administrator_login
  administrator_password        = var.administrator_password
  public_network_access_enabled = false

  storage_mb = 32768
  sku_name   = "B_Standard_B1ms"

  tags = var.tags
}