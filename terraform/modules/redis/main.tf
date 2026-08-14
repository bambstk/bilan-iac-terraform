terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
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
    access_keys_authentication_enabled   = true
  }

  tags = var.tags
}

# Zone DNS privée pour Managed Redis
resource "azurerm_private_dns_zone" "redis" {
  name                = "privatelink.redis.cache.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  name                  = "redis-${var.owner}-bilan"
  private_dns_zone_id = azurerm_private_dns_zone.redis.id
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

resource "azurerm_private_endpoint" "redis" {
  name                = "pe-redis-${var.owner}-bilan"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "redis-connection"
    private_connection_resource_id = azurerm_managed_redis.redis.id
    subresource_names              = ["redisEnterprise"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "redis-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.redis.id]
  }

  tags = var.tags
}