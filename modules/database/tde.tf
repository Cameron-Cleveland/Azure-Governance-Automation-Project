# Transparent Data Encryption Configuration
# Using Service-Managed Keys for lab (Key Vault has only 7-day retention)

# Note: Azure SQL uses Service-Managed TDE by default when no customer key is specified
# This is acceptable for lab environments

# Remove or comment out customer-managed key resources:
# They require Key Vault with 90-day soft delete retention

/*
# Customer-Managed Key for TDE - DISABLED due to Key Vault constraints
resource "azurerm_key_vault_key" "sql_tde_key" {
  name         = "sql-tde-key-\${var.environment}"
  key_vault_id = var.key_vault_id
  key_type     = "RSA"
  key_size     = 2048
  
  key_opts = [
    "unwrapKey",
    "wrapKey"
  ]
  
  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }
    
    expire_after         = "P365D"
    notify_before_expiry = "P29D"
  }
}

resource "azurerm_mssql_server_transparent_data_encryption" "tde" {
  server_id        = azurerm_mssql_server.healthcare.id
  key_vault_key_id = azurerm_key_vault_key.sql_tde_key.id
}


# Keep the access policy for future use if needed
resource "azurerm_key_vault_access_policy" "sql_managed_identity" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_mssql_server.healthcare.identity[0].principal_id
  
  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
    "Create",
    "Decrypt",
    "Encrypt",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]
}

# Output to confirm TDE status
output "tde_status" {
  value = "Service-Managed TDE enabled (Key Vault retention: 7 days - insufficient for CMK)"
  description = "TDE configuration status"
}*/
