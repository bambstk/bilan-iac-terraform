output "storage_id" {
  value = azurerm_storage_account.storage.id
}

output "storage_prim_blob_endpnt" {
  value = azurerm_storage_account.storage.primary_blob_endpoint
}