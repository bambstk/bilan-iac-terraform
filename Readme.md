# Alors... je sais pas encore comment je vais structurer cette doc, on va voir

### quelques choix

je vais les mettre en ADR plus tard:  
- github plutot que gitlab, raison personnelle, j'utilise déjà gitlab avec les briefs de steve, donc j'ai bien envie d'utiliser github ici pour rester haitué aux deux + j'ai pas configuré la verification des commits sur github alors que je l'ai déjà fait sur gitlab donc bien envie de voir comment faire ici, j'ai déjà l'habitude de dependabot en plus.  
- AKS ou Service Managé, je pars sur du service managé, pcq pour ce bilan je prefere rester sur une nouvelle technologie à la fois (terraform), et je me concentrerais sur kubernetes plus tard.
- je vais devoir faire des choix de reseau plus tard aussi, mais ce sera plus tard ça

### signer les commits

j'avais déjà créé une clé gpg pour signer mes commits gitlab sut wsl, donc j'ai décidé d'utiliser la même clé gpg pour github, étant donné que sur mon terminal cette clé elle signe mes commit git tout court, les commandes pour retrouver la clé publique (à rentrer dans les paramatres de mon profil github) c'est :  
``` gpg -k``` pour avoir la liste de mes clés gpg (j'en avais une seule ici)  
```gpg --armor --export <id-de-la-cle>``` export pour afficher, et armor pour que ce soit pas en binaire, que ce soit lisible

### le fameux schema

je vais le faire ok ??