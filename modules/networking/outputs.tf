
output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = azurerm_subnet.private.id
}

output "data_subnet_id" {
  description = "ID of the data subnet (for private endpoints)"
  value       = azurerm_subnet.data.id
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.healthcare_vnet.id
}

output "key_vault_private_dns_zone_id" {
  description = "ID of Key Vault Private DNS Zone"
  value       = azurerm_private_dns_zone.key_vault.id
}

output "sql_private_dns_zone_id" {
  description = "ID of SQL Server Private DNS Zone"
  value       = azurerm_private_dns_zone.sql_server.id
}
