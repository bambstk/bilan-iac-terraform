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

# Zone DNS privée pour PostgreSQL Flexible Server
resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

# Lien entre la zone DNS et le VNet
resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "psql-${var.owner}-bilan"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

# Private Endpoint
resource "azurerm_private_endpoint" "postgres" {
  name                = "pe-psql-${var.owner}-bilan"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psql-connection"
    private_connection_resource_id = azurerm_postgresql_flexible_server.postgres.id
    subresource_names              = ["postgresql"] # obligatoire
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "psql-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.postgres.id]
  }

  tags = var.tags
}