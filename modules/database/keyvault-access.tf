# This ensures the SQL server identity is created before access policy
resource "time_sleep" "wait_for_sql_identity" {
  depends_on = [azurerm_mssql_server.healthcare]
  
  create_duration = "30s"
}

resource "azurerm_key_vault_access_policy" "sql_managed_identity" {
  depends_on = [time_sleep.wait_for_sql_identity]
  
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

# Then update the TDE resource to depend on this
resource "azurerm_mssql_server_transparent_data_encryption" "tde" {
  server_id        = azurerm_mssql_server.healthcare.id
  key_vault_key_id = azurerm_key_vault_key.sql_tde_key.id
  
  depends_on = [
    azurerm_key_vault_key.sql_tde_key,
    azurerm_key_vault_access_policy.sql_managed_identity
  ]
}