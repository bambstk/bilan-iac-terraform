# Alors... je sais pas encore comment je vais structurer cette doc, on va voir

### Architecture Decision Records

[github plutot que gitlab](./ADR-git.md)  
[services managés plutôt qu'AKS](./ADR-service.md)  
[le reseau dans azure je comprends pas bien encore, je ferais ça au fur et à mesure]

### Signer les commits

j'avais déjà créé une clé gpg pour signer mes commits gitlab sur wsl, donc j'ai décidé d'utiliser la même clé gpg pour github, étant donné que sur mon terminal cette clé elle signe mes commit git tout court, les commandes pour retrouver la clé publique (à rentrer dans les paramatres de mon profil github) c'est :  
``` gpg -k``` pour avoir la liste de mes clés gpg (j'en avais une seule ici)  
```gpg --armor --export <id-de-la-cle>``` export pour afficher, et armor pour que ce soit pas en binaire, que ce soit lisible

### Le fameux schema

Pour l'instant la façon dont je vois l'architecture que je vais déployer c'est comme ça, on verra si ça marche vraiment, tout ça  

![schema v1](./schema_v2.png)

### Terraform

Pour commencer je vais créer le storage account qui contiendra le container avec le state distant de terraform, j'ai besoin de le faire qu'une seule fois et [la doc](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-create) dis bien comment faire.  
Puis un storage container dans le storage account ([la doc ici](https://learn.microsoft.com/en-us/cli/azure/storage/container?view=azure-cli-latest#az-storage-container-create))  

Pour trouver quoi mettre dans les .tf je vais me baser sur la [doc terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) pour commencer.  (malheuresement je trouve qu'on a pas assez le temps pour faire tous les main.tf à la main, donc j'ai envoyé les docs que j'ai trouvé à deepseek pour qu'il me genere les main.tf, j'aurais bien aimé digger les docs pour savoir ce qu'il est possible de mettre dedans, mais pas possible)

Pour créer l'infra en local, toujours:  
```terraform init``` (à refaire à chaque ajout de module)  
```terraform validate``` (+ ```terraform fmt``` pour que les fichiers soit toujours bien joli au cas où)  
```terraform plan```  
```terraform apply```

Pour passer à la creation de l'infra via github actions j'ai décidé de remettre mon .tfvars dans le gitignore, donc pour les variables qui étaient dedans j'ai fais 2 choses :  
    - pour 3 d'entre elles j'ai crée des variables dans le repo github et de ce que j'ai compris [ici](https://dev.to/bhanufyi/effective-terraform-variable-management-in-github-actions-488l) si je crée de variables d'environement qui commencent par ```TF_VAR_``` dans la CI et que je leur assigne la valeur stocké dans mes variables github ça devrait faire la même chose que le fichier .tfvars
    - pour le mot de passe je vais le faire generer directement dans terraform avec le module random, comme ça je pourrais le transmettre au modules qui ont en besoin tranquillo et le stocker dans le keyvault directement, en plus les mdp genérés automatiquement c'est pas mal niveau sécurité, bref je m'y met.

j'ai lancé le apply, comme prévu un peu de troubleshooting, mais tout se régle. CEPENDANT, comment ça le plan partagé peux avoir que 2 vnet ???
eh bien je dois créer un nouveau un nouveau plan (ou laisser tout le back en publique ce qui est ok aussi étant donné que c'est jsute un tp et que c'est justifié par le fait que le plan partagé soit trop fatigué, mais j'ai envie de créer un petit plan quand même)

Pour l'oidc de github action ça me demandais mon user ID (incomprehensible, mais bref) et c'est facilement trouvable grace à l'api github [https://api.github.com/users/bambstk]  
ça demandé l'id du repo aussi je l'ai ignoré, mais ça a pas réussi la connection, et j'ai trouvé l'id dans le message d'erreur (après ça doit être trouvable sur l'api facielment aussi), c'est ça l'url pour les repos : [https://api.github.com/repos/bambstk/bilan-iac-frontend]

j'ai eu quelques problème de lock sur terraform avec mes TF_VAR que j'oubliais partout et les workflow que j'ai du cancel sans que ça libere le lock, donc la commande magique pour éteindre le lock c'est ```terraform force-unlock <numero-de-lock>```

un keyvault ça se supprime pas directement, il faut attednre 90 jours pendant lesquels il est encore possible de le recuperer, donc chiant pour les apply après les destroy, donc il faut un nom random pour le vault.

une fois que tout est crée je dois mettre des droit sur le storage à mon back :

```bash
PS C:\Users\Utilisateur\espace_de_travail\Bilan_iac_cd\bilan-iac-terraform\terraform> az webapp identity show --name back-sbaivloann-bilan --resource-group lzniberRG --query principalId -o tsv
784e05b9-c39e-4358-89c4-af83eeb47248
PS C:\Users\Utilisateur\espace_de_travail\Bilan_iac_cd\bilan-iac-terraform\terraform> az storage account show --name stsbaivloannbilan --resource-group lzniberRG --query id -o tsv
/subscriptions/5e683e0f-b00c-48d6-9769-5aaf598de8f1/resourceGroups/lzniberRG/providers/Microsoft.Storage/storageAccounts/stsbaivloannbilan
PS C:\Users\Utilisateur\espace_de_travail\Bilan_iac_cd\bilan-iac-terraform\terraform> az role assignment create --assignee 784e05b9-c39e-4358-89c4-af83eeb47248 --scope /subscriptions/5e683e0f-b00c-48d6-9769-5aaf598de8f1/resourceGroups/lzniberRG/providers/Microsoft.Storage/storageAccounts/stsbaivloannbilan --role "Storage Blob Data Contributor"
```  
dans le vrai .md je le mettrais proprement

et pour me donner la permission de voir ce qu'il y a dans le vault (quand il a été crée par le service principal) :  
```az keyvault set-policy --name kv-sbaivloann-bilan-mou --object-id 0be1d50e-08f9-4990-af02-84aacbf5f6ed --secret-permissions get list```

## BONUS !!! double environement github (flemme)

### student c'est flingué

déjà va falloir que je me crée un nouveau service principal sur cette sub, flemme, je vais essayer de retrouver les commandes que j'avais utilisé pour créer celui de simplongue.  
j'ai mis du temps et je me suis dispersé sur d'autres sujets désolé, bon en gros j'ai fait :  
`az ad app create --display-name bilan-iac-prod-buambinho` pour créer l'app service qui va contenir le service principal (c'est un vraiment un service principal ? en tout cas c'est une microsoft entra app)  
normalement on peut voir l'AppId en sortie de commande, mais si besoin `az ad app list --display-name bilan-iac-prod-buambinho --query "[0].{appId:appId}"` avec en option `-o tsv` si on veut que ce soit plus joli  
`az ad sp create --id <AppId>` pour créer le service principal  

maintenant il me faut la subscription id, tenant id, et client id pour l'oidc, j'crois c'est pas trop compliqué de les cop sur le portail, mais j'aimerais bien les cop en cli, donc:  
`az account show --query id -o tsv` montre l'id de la sub associé au compte au moment de faire la commande  
`az account show --query tenantId -o tsv` pareil pour le tenant  
et le clientID c'est le appId donc y a déjà la commande plus haut.

j'ai l'habitude d'ajouter les identités federées via le portail azure en allant dans l'app service > gerer > certificats et secrets > infos d'id fedérés pour gitlab il faut cette nomenclature "emeteur: https://gitlab.com" et "valeur: project_path:<OWNER>/<REPO>:ref_type:branch:ref:main", et pour github c'est encore plus simple (il faut juste recuperer les id avec l'api github), donc je vais essayer le faire en CLI maintenant:  
```bash
az ad app federated-credential create \
    --id <APP_ID> \
    --parameters '{
        "name": "NomDeLaCredential",
        "issuer": "https://token.actions.githubusercontent.com",
        "subject": "repo:<OWNER>/<REPO>:<TYPE>:<VALEUR>",
        "audiences": ["api://AzureADTokenExchange"]
    }'
```  
là je veux que ça login sur main en normal mais surtout dans l'environement qui s'appelle prod donc en subject il va me falloir (en plusieur commandes):  
`repo:<OWNER>/<REPO>:ref:refs/heads/<BRANCHE>` et `repo:<OWNER>/<REPO>:environment:<ENV_NAME>` (pour un PR ce serait : `repo:<OWNER>/<REPO>:pull_request`)  
il faut que j'ajoute l'environement su la sp de ma sub simplon aussi. (et pour chacun des repos, donc 9 fois en tout avec une petite modif à chaque fois....)  

il faut aussi que je recrée le storage pour le state dans la sub student comme au début du md.  
je sais pas c'est quoi cette nouvelle connerie à la mode chez azure, mais j'avais pas le droit de créer de stroage account en cli tant que j'avaias pas register ma sub student ?? c'est quoi cette histoire encore, toujours plus d'étape bizarres et qui ont l'air inutiles avec azure, ça saoule pas mal...  
```bash
user@OCCPC5CD90419JS /mnt/c/Users/Utilisateur/espace_de_travail/Bilan_iac_cd/bilan-iac-terraform  (main)$ az provider show --namespace Microsoft.Storage --query "registrationState"
"NotRegistered"
user@OCCPC5CD90419JS /mnt/c/Users/Utilisateur/espace_de_travail/Bilan_iac_cd/bilan-iac-terraform  (main)$ az provider register --namespace Microsoft.Storage
Registering is still on-going. You can monitor using 'az provider show -n Microsoft.Storage'
```  
alors là azure student flingué de zinzin, pour trouvé les 5 locations où j'ai le droit de créer le storage, j'ai du srotir cette infame commande mdr  
`az policy assignment list --subscription 49ac968d-5d1d-4bd8-8a34-fe14f0c7c253 --query "[?contains(policyDefinitionId, 'allowed-locations') || contains(displayName, 'Allowed')].[name, displayName, parameters]" -o json`  
et j'ai du ajouter ` --sku Standard_LRS` à la création pcq par defaut ça mettait `Standard_RAGRS` et que c'est pas autorisé, bien chiant azure student, bref.