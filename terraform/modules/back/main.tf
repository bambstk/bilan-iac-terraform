terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_linux_web_app" "back" {
  name                = "back-${var.owner}-bilan"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id
  https_only          = "true"

  site_config {
    application_stack {
      java_server = "JAVA"
      java_server_version = "21"
      java_version = "21"
    }
    cors {
      
    }
  }

  tags                = var.tags
}