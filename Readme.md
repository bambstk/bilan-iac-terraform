# Alors... je sais pas encore comment je vais structurer cette doc, on va voir

### quelques choix

je vais les mettre en ADR plus tard:  
- github plutot que gitlab, raison personnelle, j'utilise déjà gitlab avec les briefs de steve, donc j'ai bien envie d'utiliser github ici pour rester haitué aux deux + j'ai pas configuré la verification des commits sur github alors que je l'ai déjà fait sur gitlab donc bien envie de voir comment faire ici, j'ai déjà l'habitude de dependabot en plus.  
- AKS ou Service Managé, je pars sur du service managé, pcq pour ce bilan je prefere rester sur une nouvelle technologie à la fois (terraform), et je me concentrerais sur kubernetes plus tard.
- je vais devoir faire des choix de reseau plus tard aussi, mais ce sera plus tard ça

### signer les commits

j'avais déjà créé une clé gpg pour signer mes commits gitlab sur wsl, donc j'ai décidé d'utiliser la même clé gpg pour github, étant donné que sur mon terminal cette clé elle signe mes commit git tout court, les commandes pour retrouver la clé publique (à rentrer dans les paramatres de mon profil github) c'est :  
``` gpg -k``` pour avoir la liste de mes clés gpg (j'en avais une seule ici)  
```gpg --armor --export <id-de-la-cle>``` export pour afficher, et armor pour que ce soit pas en binaire, que ce soit lisible

### le fameux schema

je vais le faire ok ??
dans le biref ça nous parle de sku donc c'est pour les vm ça, mais je vois pas à quel moment je vais utiliser une vm là ?
    - ok j'ai capté que les sku c'est pas que pour les vm mais aussi les services managés, donc va falloir que je regarde quels sont les moins cher que je peux utiliser dans cette subscription.
je vois pas encore trop à quoi ça sert redis, ni pourquoi on a besoin d'un storage account et d'une DB postgre donc je vais demander à mon ia chinoise préférée, deepseek.
    - ok j'ai mieux compris l'architecture backend, c'est vrai qu'au final y avait tout dans le readme du backend, et j'ai compris comment ça fonctionnait l'architecture CORS + clé api
j'ai cependant un peu mal à la tête et je suis fatigué là, donc je vais prendre mon temps pour commencer le schema et je le finirais demain matin je pense