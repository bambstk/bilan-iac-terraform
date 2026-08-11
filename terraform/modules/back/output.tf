# Cet output est utilisé dans outputs.tf racine pour construire l'URL
output "default_hostname" {
  value = azurerm_linux_web_app.back.default_hostname
}

output "identity_principal_id" {
  value = azurerm_linux_web_app.back.identity[0].principal_id
}