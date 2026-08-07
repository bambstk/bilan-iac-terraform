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
ça demandé l'id du repo aussi je l'ai ignoré, mais ça a pas réussi la connection, et j'ai trouvé l'id dans le message d'erreur (après ça doit être trouvable sur l'api facielment aussi)