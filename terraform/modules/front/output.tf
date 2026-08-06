# Cet output est utilisé dans outputs.tf racine pour construire l'URL
output "front_default_hostname" {
  value = azurerm_static_web_app.front.default_host_name
}
