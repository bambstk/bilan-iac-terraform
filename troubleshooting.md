# Troubleshooting Bilan IAC

Ce document résume les principaux problèmes rencontrés et leurs solutions lors du déploiement de l’infrastructure Azure et des applications.

---

## 1. Terraform – Infrastructure

### 1.1. Static Web App : localisation non supportée
**Erreur** :  
`LocationNotAvailableForResourceType: The provided location 'francecentral' is not available for resource type 'Microsoft.Web/staticSites'`

**Cause** : Azure Static Web Apps n’est pas disponible dans toutes les régions (limité à `centralus`, `eastus2`, `westus2`, `westeurope`, `eastasia`).  
**Solution** : Forcer la localisation du module `front` à `westeurope`.

### 1.2. Key Vault : accès interdit lors de la création du secret
**Erreur** :  
`Public network access is disabled and request is not from a trusted service nor via an approved private link.` (403 Forbidden)

**Cause** : Le Key Vault avait `public_network_access_enabled = false`, et la création du secret via Terraform nécessitait un accès au plan de données.  
**Solution** : Passer temporairement `public_network_access_enabled = true` pour appliquer, puis remettre à `false` (pour l'instant on laisse à `true` quand même car ça entraine d'autres problemes).

### 1.3. Private Endpoint PostgreSQL : GroupId incorrect
**Erreur** :  
`IncorrectPrivateLinkServiceConnectionGroupId: Call to Microsoft.DBforPostgreSQL/flexibleServers failed.`

**Cause** : Le `subresource_names` attendu pour PostgreSQL Flexible Server était `postgresqlServer` (avec une majuscule), et non `postgresql`.  
**Solution** : Utiliser `subresource_names = ["postgresqlServer"]`.

### 1.4. Zone PostgreSQL Flexible Server : erreur de modification
**Erreur** :  
`zone can only be changed when exchanged with the zone specified in high_availability.0.standby_availability_zone`

**Cause** : Le serveur avait une zone attribuée automatiquement, et Terraform tentait de la supprimer.  
**Solution** : Ajouter `zone = "1"` et `lifecycle { ignore_changes = [zone] }`.

### 1.5. Erreur CORS sur App Service back lors du premier déploiement
**Erreur** :  
`Provider produced inconsistent final plan ... block count changed from 0 to 1`

**Cause** : Le bloc `cors` a été ajouté après la création initiale de l’App Service.  
**Solution** : Forcer la recréation de la ressource (ou déployer le backend avec le bloc CORS dès le départ). Avec la VNet Integration ajoutée plus tard, le souci ne s’est pas reproduit.

### 1.6. Soft delete Key Vault – conflit de nom
**Erreur** :  
`A vault with the same name already exists in deleted state.`

**Cause** : Après un `destroy`, le Key Vault reste en soft delete pendant 90 jours. Le `random_string` ne changeant pas, le même nom était réutilisé.  
**Solution** : Désactiver la purge automatique (`key_vault { purge_soft_delete_on_destroy = false }`) et utiliser un suffixe aléatoire (`random_string`) avec une longueur modifiée si nécessaire pour générer un nouveau nom.

### 1.7. Verrou d’état Terraform bloqué
**Erreur** :  
`state blob is already locked`

**Cause** : Un job GitHub Actions annulé a laissé un verrou sur l’état distant.  
**Solution** : Forcer la libération avec `terraform force-unlock <lock-id>`.

### 1.8. Erreur `attribute redefined` dans lifecycle
**Erreur** :  
`The argument "ignore_changes" was already set`

**Cause** : Deux blocs `ignore_changes` dans le même `lifecycle`.  
**Solution** : Combiner les attributs : `ignore_changes = [zone, administrator_password]`.

### 1.9. Plan App Service partagé : limite VNet Integration dépassée
**Erreur** :  
`Adding this VNET would exceed the App Service Plan VNET limit of 2.`

**Cause** : Le plan mutualisé fourni n’autorisait que 2 intégrations VNet.  
**Solution** : Créer un plan dédié (`azurerm_service_plan` avec `sku_name = "B1"`) dans le module réseau et l’utiliser pour le backend.

---

## 2. GitHub Actions / CI/CD

### 2.1. OIDC non configuré pour un dépôt
**Erreur** : Échec de connexion Azure (`AuthorizationFailed`).  
**Solution** : Ajouter un `federated credential` dans l’App Registration Azure avec le `subject` correct (`repo:<org>/<repo>:ref:refs/heads/main`). Récupérer l’ID du repo via `https://api.github.com/repos/<org>/<repo>`.

### 2.2. Variables Terraform manquantes dans le workflow
**Erreur** : Le job restait bloqué en attente interactive (`var.owner`).  
**Solution** : Définir les variables `TF_VAR_` au niveau du job ou de l’étape.

### 2.3. Récupération des secrets depuis Key Vault
**Astuce** : Utiliser `echo "VAR=$VAR" >> $GITHUB_ENV` pour transmettre une variable entre les étapes.  
**Exemple** : `VAULT_NAME` et `SWA_TOKEN`.

---

## 3. Frontend (Angular + Static Web App)

### 3.1. Substitution des placeholders dans `environment.ts`
**Problème** : Le workflow devait remplacer `REPLACE_WITH_PROD_API_URL` et `__BACKEND_API_KEY__`.  
**Solution** : Utiliser `sed` après avoir récupéré l’URL du backend et la clé API depuis Azure (via tags). Vérifier que les chemins sont corrects.

### 3.2. Erreur CORS lors des appels API
**Symptôme** : Message `Blocage d’une requête multiorigines... Access-Control-Allow-Origin manquant` dans la console.  
**Cause** : L’`APP_CORS_ALLOWED_ORIGINS` ne correspondait pas à l’URL du front.  
**Solution** : Mettre à jour la variable d’environnement du backend avec l’URL exacte de la Static Web App (ex: `https://yellow-stone-...`), sans slash final.

### 3.3. Message d’erreur `file:///` dans la console
**Explication** : Erreur de sécurité mineure, souvent liée à un service worker ou à un chargement de ressource. N’empêche pas le fonctionnement.

---

## 4. Backend (Spring Boot + App Service)

### 4.1. Base de données `azurequiz` inexistante
**Erreur** :  
`FATAL: database "azurequiz" does not exist`

**Cause** : La base de données n’était pas créée automatiquement par le serveur PostgreSQL Flexible Server.  
**Solution** : Ajouter une ressource `azurerm_postgresql_flexible_server_database` avec `name = "azurequiz"`.

### 4.2. Échec d’authentification PostgreSQL (mot de passe incorrect)
**Erreur** :  
`FATAL: password authentication failed for user "unpeuadmin"`

**Cause** : Le `lifecycle { ignore_changes = [administrator_password] }` empêchait la mise à jour du mot de passe lors d’un `apply`.  
**Solution** : Retirer temporairement `administrator_password` du `ignore_changes`, appliquer, puis le remettre éventuellement.

### 4.3. Erreur 403 sur le stockage (Blob) au démarrage
**Erreur** :  
`Status code 403, AuthorizationFailure`

**Cause** : L’identité managée de l’App Service n’avait pas les droits sur le compte de stockage.  
**Solution** : Attribuer le rôle `Storage Blob Data Contributor` à l’identité managée de l’App Service, soit manuellement via `az role assignment create`, soit dans Terraform (`azurerm_role_assignment`).

### 4.4. `REDIS_PASSWORD` vide
**Problème** : L’authentification par clé d’accès était désactivée sur Azure Managed Redis.  
**Solution** : Activer `access_keys_authentication_enabled = true` dans le bloc `default_database` de la ressource `azurerm_managed_redis`, exporter `primary_access_key`, et l’injecter dans `app_settings` du backend.

### 4.5. Erreur 500 persistante sur `/api/certifications`
**Symptôme** : Le backend démarre correctement, se connecte à PostgreSQL et Redis, mais l’endpoint `/api/certifications` renvoie une erreur 500.  
**Cause probable** : Exception applicative non capturée (peut être une erreur SQL, un problème de sérialisation JSON, ou un souci avec le cache Redis).  
#### 4.5.1 Azure Managed Redis : erreur `RedisConnectionFailureException: Unable to connect to Redis`

**Symptôme** : Le backend démarre, se connecte à PostgreSQL, mais l'endpoint `/api/certifications` renvoie une erreur 500 avec dans les logs :

```org.springframework.data.redis.RedisConnectionFailureException: Unable to connect to Redis```



**Cause** : La zone DNS privée utilisée pour le Private Endpoint de Redis était incorrecte.  
Pour **Azure Managed Redis** (Redis Enterprise), la zone DNS privée attendue est :

- `privatelink.redis.azure.net`

Or, dans le module Terraform, on avait utilisé :

- `privatelink.redis.cache.azure.net`  
  → c’est la zone pour **Azure Cache for Redis classique**, pas pour Managed Redis.

Le backend résolvait donc le nom public de Redis, inaccessible car `public_network_access = "Disabled"`.

**Solution** : Modifier `modules/redis/main.tf` :

```hcl
resource "azurerm_private_dns_zone" "redis" {
  name                = "privatelink.redis.azure.net"   # et non redis.cache.azure.net
  resource_group_name = var.resource_group_name
}
```

---

## 5. Commandes utiles

```bash
# Terraform
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform destroy
terraform force-unlock <lock-id>

# Azure CLI – Key Vault
az keyvault set-policy --name <vault-name> --object-id <object-id> --secret-permissions get list
az keyvault secret show --vault-name <vault-name> --name <secret-name> --query value -o tsv

# Azure CLI – App Service
az webapp config appsettings list --name back-sbaivloann-bilan --resource-group lzniberRG
az webapp config appsettings set --name back-sbaivloann-bilan --resource-group lzniberRG --settings KEY=VALUE
az webapp log tail --name back-sbaivloann-bilan --resource-group lzniberRG
az webapp ssh --name back-sbaivloann-bilan --resource-group lzniberRG

# Azure CLI – Redis
az redisenterprise database list-keys --cluster-name redis-sbaivloann-bilan --resource-group lzniberRG --database-name default

# GitHub API
curl -s https://api.github.com/repos/<org>/<repo> | jq '.id'

# Activer des logs DEBUG supplémentaires
# Pour Spring Data Redis, le cache, Hibernate SQL et le package applicatif :
az webapp config appsettings set --name back-sbaivloann-bilan --resource-group lzniberRG \
  --settings logging.level.org.springframework.data.redis=DEBUG \
             logging.level.org.springframework.cache=DEBUG \
             logging.level.org.hibernate.SQL=DEBUG \
             logging.level.com.alderichoarau.azurequiz=DEBUG
az webapp restart --name back-sbaivloann-bilan --resource-group lzniberRG

# Pour suivre les logs
az webapp log tail --name back-sbaivloann-bilan --resource-group lzniberRG
```
