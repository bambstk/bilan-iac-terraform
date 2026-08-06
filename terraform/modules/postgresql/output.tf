output "psql_id" {
  value = azurerm_postgresql_flexible_server.postgres.id
}

output "psql_fqdn" {
  value = azurerm_postgresql_flexible_server.postgres.fqdn
}

output "psql_server_name" {
  value = azurerm_postgresql_flexible_server.postgres.name
}