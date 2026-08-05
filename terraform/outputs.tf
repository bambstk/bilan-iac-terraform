# ──────────────────────────────────────────────────────────────────────────────
# outputs.tf — Valeurs exposées après terraform apply
#
# Les outputs sont l'équivalent des `echo` à la fin de provision.sh.
# Complétez au fur et à mesure que vous créez les ressources.
# ──────────────────────────────────────────────────────────────────────────────

# URLs du front et du back
output "front_url" {
  value = "https://${module.front.default_hostname}"
}

output "back_url" {
  value = "https://${module.back.default_hostname}"
}
