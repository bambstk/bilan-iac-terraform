terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                       = "kv-${var.owner}-bilan"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = false
  purge_protection_enabled   = false
  public_network_access_enabled = false

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

  tags = var.tags
}