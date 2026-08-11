# ──────────────────────────────────────────────────────────────────────────────
# main.tf — Ressources Azure à provisionner avec Terraform
#
# Ce fichier est votre point d'entrée. Complétez les TODO au fil du TP.
# ──────────────────────────────────────────────────────────────────────────────

# ── Tags communs à toutes les ressources ──────────────────────────────────────
# Ces tags sont mergés automatiquement dans chaque module via var.tags

locals {
  tags = merge(
    {
      managed_by  = "terraform"
      environment = "bilan-iac"
      owner       = var.owner
    },
    var.tags
  )
}

# ── Data sources ──────────────────────────────────────────────────────────────
# Un data source LIT une ressource existante sans la créer.

# Resource Group pré-créé — ne jamais le gérer en Terraform
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}

# data "azurerm_service_plan" "shared" {
#   name                = var.shared_plan_name
#   resource_group_name = var.shared_rg_name
# }

# ── Front  ─────────────────────────────────────────────────────────

module "front" {
  source = "./modules/front"

  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  kv_id               = module.keyvault.kv_id
  tags                = merge(local.tags, { component = "front" })
}


# ── Back  ─────────────────────────────────────────────────────────

module "back" {
  source = "./modules/back"

  owner                 = var.owner
  resource_group_name   = data.azurerm_resource_group.rg.name
  location              = var.location
  service_plan_id       = module.network.backend_plan_id
  integration_subnet_id = module.network.integration_subnet_id
  db_host               = module.postgresql.psql_fqdn
  kv_id                 = module.keyvault.kv_id
  frontend_url          = module.front.front_default_hostname
  administrator_login   = var.administrator_login
  redis_hostname        = module.redis.redis_hostname
  redis_password        = module.redis.primary_access_key
  redis_port            = module.redis.redis_port
  storage_account_name  = module.storage.storage_account_name
  kv_uri                = module.keyvault.kv_uri

  tags = merge(local.tags, { component = "back" })
}

# ── Network  ───────────────────────────────────────────────────────

module "network" {
  source = "./modules/network"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = merge(local.tags, { component = "network" })
}

# ── postgresql  ─────────────────────────────────────────────────────

module "postgresql" {
  source = "./modules/postgresql"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  administrator_login = var.administrator_login
  subnet_id           = module.network.private_endpoints_subnet_id
  vnet_id             = module.network.vnet_id
  kv_id               = module.keyvault.kv_id
  tags                = merge(local.tags, { component = "postSQL" })
}

# ── redis  ───────────────────────────────────────────────────────────

module "redis" {
  source = "./modules/redis"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = module.network.private_endpoints_subnet_id
  vnet_id             = module.network.vnet_id
  tags                = merge(local.tags, { component = "redis" })
}

# ── storage  ───────────────────────────────────────────────────────────

module "storage" {
  source = "./modules/storage"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = module.network.private_endpoints_subnet_id
  vnet_id             = module.network.vnet_id
  tags                = merge(local.tags, { component = "storage" })
}

# ── keyvault  ───────────────────────────────────────────────────────────

module "keyvault" {
  source = "./modules/keyvault"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = module.network.private_endpoints_subnet_id
  vnet_id             = module.network.vnet_id
  public_access       = var.kv_public_access
  tags                = merge(local.tags, { component = "keyvault" })
}

# ── jesaismemeplus  ───────────────────────────────────────────────────

resource "azurerm_key_vault_access_policy" "app_service" {
  key_vault_id = module.keyvault.kv_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = module.back.identity_principal_id

  secret_permissions = ["Get", "List"]
}