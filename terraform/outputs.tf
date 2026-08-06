# ──────────────────────────────────────────────────────────────────────────────
# outputs.tf — Valeurs exposées après terraform apply
#
# Les outputs sont l'équivalent des `echo` à la fin de provision.sh.
# Complétez au fur et à mesure que vous créez les ressources.
# ──────────────────────────────────────────────────────────────────────────────

# URLs du front et du back
output "front_url" {
  value = "https://${module.front.front_default_hostname}"
}

output "back_url" {
  value = "https://${module.back.default_hostname}"
}


output "key_vault_name" {
  value = module.keyvault.kv_name
}

output "postgresql_server_name" {
  value = module.postgresql.psql_server_name
}