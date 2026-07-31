# Choix de GitHub comme plateforme de CI/CD et dépôts

## Status
Accepté.

## Context
Le projet impose d’avoir un pipeline CI/CD, avec au choix GitHub Actions ou GitLab CI. Les trois dépôts doivent être hébergés sur la même plateforme.

## Decision
Je pars sur GitHub. Déjà parce que c’est une raison perso : j’utilise GitLab sur les briefs de Steve, donc j’ai bien envie d’utiliser GitHub ici pour rester habitué aux deux. J’ai pas encore configuré la vérification des commits sur GitHub alors que je l’ai déjà fait sur GitLab, donc bien envie de voir comment faire ici. En plus j’ai déjà l’habitude de Dependabot sur GitHub, ça me fait gagner du temps.

## Consequences
- La CI sera écrite avec GitHub Actions.
- Je vais devoir configurer la signature de commits GPG/SSH spécifiquement pour GitHub.
- Dependabot sera activé sur les trois dépôts, ce qui est déjà un réflexe pour moi.
- Je garde la main sur les deux plateformes, ce qui me va bien pour la suite.