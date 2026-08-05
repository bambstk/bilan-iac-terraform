output "psql_id" {
    value = azurerm_postgresql_flexible_server.postgres.id
}

output "psql_dn" {
    value = azurerm_postgresql_flexible_server.postgres.private_dns_zone_id  
}