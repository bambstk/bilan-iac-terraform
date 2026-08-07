# Infrastructure as Code – Bilan IAC

Déploiement automatisé d’une infrastructure Azure non‑production composée de services managés (App Service, Static Web App, PostgreSQL, Redis, Storage, Key Vault).  
Le provisionnement est entièrement réalisé avec Terraform et orchestré via GitHub Actions.

## Architecture

![Schéma d'architecture](./schema_v2.png)

## Décisions d’architecture

- [GitHub plutôt que GitLab](./ADR-git.md)
- [Services managés plutôt qu’AKS](./ADR-service.md)

## Structure du dépôt

```
└── terraform/
│   ├── main.tf                 # Point d'entrée racine
│   ├── variables.tf            # Déclarations des variables
│   ├── outputs.tf              # Sorties exposées (URLs, noms…)
│   ├── providers.tf            # Provider AzureRM + configuration OIDC
│   ├── backend.tf              # Backend distant (Azure Blob Storage)
│   └── modules/
│       ├── front/              # Static Web App
│       ├── back/               # App Service Linux (backend)
│       ├── network/            # Réseau virtuel + sous‑réseaux
│       ├── postgresql/         # PostgreSQL Flexible Server
│       ├── redis/              # Azure Managed Redis
│       ├── storage/            # Compte de stockage
│       └── keyvault/           # Key Vault
└─ .github/workflows/      # Pipeline CI/CD
```

## Prérequis

- Compte Azure avec les droits suffisants
- Stockage de l’état distant déjà créé
- Service principal configuré pour l’authentification OIDC avec GitHub Actions
- Variables GitHub Actions renseignées (voir CI/CD)

## Déploiement local

```bash
cd terraform
terraform init
terraform validate
terraform fmt
terraform plan -out=tfplan
terraform apply tfplan
```

Les variables sensibles (owner, resource group, login administrateur PostgreSQL) sont à renseigner dans un fichier `terraform.tfvars` (non versionné) ou via des variables d’environnement `TF_VAR_...`.

## CI/CD avec GitHub Actions

Le workflow `Terraform Deploy` est déclenché manuellement (`workflow_dispatch`) avec le choix entre `apply` et `destroy`.

- Authentification OIDC : les secrets `CLIENT_ID`, `TENANT_ID`, `SUBSCRIPTION_ID` doivent être configurés dans les `vars` du dépôt.
- Variables Terraform : les valeurs `OWNER`, `RG_NAME`, `ADMIN_LOGIN` sont passées via `TF_VAR_` dans l’environnement du job.
- Le mot de passe administrateur PostgreSQL est généré automatiquement par Terraform (`random_password`) et stocké dans Key Vault.

## Gestion des secrets et du Key Vault

- Le mot de passe administrateur de PostgreSQL est généré aléatoirement par la ressource `random_password` et stocké dans le Key Vault via `azurerm_key_vault_secret`.
- De base il était prévu que Key Vault soit en accès public pendant la création des secrets, puis repasse en privé après l’étape d’initialisation, mais ça créait des problèmes alors il reste publique pour l'instant.
- **Soft delete** : un Key Vault supprimé reste récupérable pendant 90 jours, ce qui bloque la recréation avec le même nom. Pour cette raison, un suffixe aléatoire est ajouté au nom du coffre (`random_string`).
