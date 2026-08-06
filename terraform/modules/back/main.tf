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

  virtual_network_subnet_id = var.integration_subnet_id

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "API_KEY"               = "@Microsoft.KeyVault(SecretUri=${var.kv_id})"
    "SPRING_DATASOURCE_URL" = "jdbc:postgresql://${var.db_host}:5432/mydb"
    # ...
  }

  site_config {
    application_stack {
      java_server         = "JAVA"
      java_server_version = "21"
      java_version        = "21"
    }
    cors {
      allowed_origins     = ["https://${var.frontend_url}"]
      support_credentials = false
    }
  }

  tags = var.tags
}