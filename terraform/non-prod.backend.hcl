# Remote state stored in Azure Blob Storage
# Backend config values are injected at runtime via -backend-config in CI
# or via a backend.hcl file locally (never commit secrets here)

resource_group_name  = "lzniberRG"
storage_account_name = "tfstatebilaniac"
container_name       = "tfstate"
key                  = "leith.terraform.tfstate"