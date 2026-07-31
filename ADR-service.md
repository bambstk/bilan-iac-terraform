# Cible d’infrastructure : Azure App Service + Static Web Apps

## Status
Accepté.

## Context
Le cahier des charges propose deux cibles : services managés (App Service + Static Web App) ou AKS (Azure Kubernetes Service). Il faut en choisir une et s’y tenir pour tout le TP.

## Decision
Je pars sur du service managé. Pour ce bilan je préfère rester sur une nouvelle techno à la fois : je découvre déjà Terraform, donc je mets Kubernetes de côté pour l’instant. Je me concentrerai sur AKS plus tard, quand j’aurai bien digéré l’infra as code.

## Consequences
- Le backend sera hébergé sur un App Service, le frontend sur une Static Web App.
- Je vais devoir gérer la contrainte réseau avec le palliatif CORS + clé API, parce que le linked backend de Static Web Apps ne permet pas d’isolation réseau totale.
- Je ne manipule pas de cluster Kubernetes ni de namespace, ce qui simplifie la stack pour ce TP.
- Ça retarde ma montée en compétence sur AKS, mais me permet de prendre plus de temps pour terraform.