output "redis_id" {
  value = azurerm_managed_redis.redis.id
}

output "redis_hostname" {
  value = azurerm_managed_redis.redis.hostname
}

output "redis_port" {
  value = azurerm_managed_redis.redis.default_database[0].port
}