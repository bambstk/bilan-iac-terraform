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

# Plan App Service partagé (dans un Resource Group séparé)
data "azurerm_service_plan" "shared" {
  name                = var.shared_plan_name
  resource_group_name = var.shared_rg_name
}

# ── Front  ─────────────────────────────────────────────────────────

module "front" {
  source = "./modules/front"

  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  tags                = merge(local.tags, { component = "front" })
}


# ── Back  ─────────────────────────────────────────────────────────

module "back" {
  source = "./modules/back"

  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  service_plan_id     = data.azurerm_service_plan.shared.id
  tags                = merge(local.tags, { component = "back" })
}

# ── Network  ───────────────────────────────────────────────────────

module "network" {
  source = "./modules/network"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# ── postgresql  ─────────────────────────────────────────────────────

module "postgresql" {
  source = "./modules/postgresql"

  owner                  = var.owner
  resource_group_name    = var.resource_group_name
  location               = var.location
  tags                   = var.tags
  administrator_login    = "ok"
  administrator_password = "ok"
}

# ── redis  ───────────────────────────────────────────────────────────

module "redis" {
  source = "./modules/redis"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# ── storage  ───────────────────────────────────────────────────────────

module "storage" {
  source = "./modules/storage"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# ── keyvault  ───────────────────────────────────────────────────────────

module "keyvault" {
  source = "./modules/keyvault"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}