terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_static_web_app" "front" {
  name                = "front-${var.owner}-bilan"
  resource_group_name = var.resource_group_name
  location            = var.location
}