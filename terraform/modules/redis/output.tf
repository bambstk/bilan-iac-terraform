output "redis_id" {
  value = azurerm_managed_redis.redis.id
}

output "redis_hostname" {
  value = azurerm_managed_redis.redis.hostname
}

output "primary_access_key" {
  value     = azurerm_managed_redis.redis.default_database[0].primary_access_key
  sensitive = true
}

output "redis_port" {
  value = azurerm_managed_redis.redis.default_database[0].port
}