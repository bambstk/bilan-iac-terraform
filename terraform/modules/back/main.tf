terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

resource "azurerm_linux_web_app" "back" {
  name                = "back-${var.owner}-bilan"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id
  https_only          = true

  virtual_network_subnet_id = var.integration_subnet_id

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "SPRING_DATASOURCE_URL"      = "jdbc:postgresql://${var.db_host}:5432/azurequiz"
    "SPRING_DATASOURCE_USERNAME"  = var.administrator_login
    "SPRING_DATASOURCE_PASSWORD"  = "@Microsoft.KeyVault(SecretUri=${var.kv_uri}secrets/postgres-admin-password/)"
    "APP_CORS_ALLOWED_ORIGINS"    = "https://${var.frontend_url}"
    "REDIS_HOSTNAME"             = var.redis_hostname
    "REDIS_PORT"                 = var.redis_port
    "REDIS_PASSWORD"             = var.redis_password
    "REDIS_SSL_ENABLED"          = "true"
    "BACKEND_API_KEY"            = "@Microsoft.KeyVault(SecretUri=${var.kv_uri}secrets/backend-api-key/)"
    "STORAGE_ACCOUNT_NAME"       = var.storage_account_name
    "STORAGE_CONTAINER_NAME"     = "java-uploads-${var.owner}"
    "SPRING_PROFILES_ACTIVE"     = "prod"
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