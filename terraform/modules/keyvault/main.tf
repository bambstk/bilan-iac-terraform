terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
  }
}

data "azurerm_client_config" "current" {}

resource "random_string" "kv_suffix" {
  length  = 3
  special = false
  upper   = false
}

resource "azurerm_key_vault" "kv" {
  name                          = "kv-${var.owner}-bilan-${random_string.kv_suffix.result}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = false
  purge_protection_enabled      = false
  public_network_access_enabled = var.public_access

  # Donne les droits de gestion au principal qui exécute Terraform
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create", "Delete", "Update", "Backup", "Restore", "Recover", "Purge"
    ]
    secret_permissions = [
      "Get", "List", "Set", "Delete", "Backup", "Restore", "Recover", "Purge"
    ]
    storage_permissions = [
      "Get", "List", "Set", "Delete", "Backup", "Restore", "Recover", "Purge"
    ]
  }

  lifecycle {
    ignore_changes = [name]
  }
  
  tags = var.tags
}

resource "random_password" "backend_api_key" {
  length  = 32
  special = false
}

resource "azurerm_key_vault_secret" "backend_api_key" {
  name         = "backend-api-key"
  value        = random_password.backend_api_key.result
  key_vault_id = azurerm_key_vault.kv.id
}

# Zone DNS privée pour Key Vault
resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv" {
  name                  = "kv-${var.owner}-bilan"
  private_dns_zone_id = azurerm_private_dns_zone.kv.id
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

resource "azurerm_private_endpoint" "kv" {
  name                = "pe-kv-${var.owner}-bilan"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "kv-connection"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "kv-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv.id]
  }

  tags = var.tags
}