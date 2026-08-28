# Remote state stored in Azure Blob Storage
# Backend config values are injected at runtime via -backend-config in CI
# or via a backend.hcl file locally (never commit secrets here)
terraform {
  backend "azurerm" {
    resource_group_name  = "Leith_letudiant"
    storage_account_name = "tfstatebilaniac2"
    container_name       = "tfstate"
    key                  = "leith.terraform.tfstate"
  }
}