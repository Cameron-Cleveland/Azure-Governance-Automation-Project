# HIPAA Compliance Audit Logging for SQL Server
resource "random_id" "audit_suffix" {
  byte_length = 4
}

resource "azurerm_storage_account" "sql_audit_logs" {
  name                     = "sqlaudit${random_id.audit_suffix.hex}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
    # Enable blob versioning for audit trail
  blob_properties {
    versioning_enabled = true
  }
  
  # Enable advanced threat protection
  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 365
    }
  }


  tags = merge(var.tags, {
    "Compliance"    = "HIPAA",
    "Purpose"       = "SQL-Audit-Logs",
    "RetentionDays" = "365",
    "DataClass"     = "Restricted"
  })
}

# SQL Server Extended Auditing Policy (HIPAA Compliance)
resource "azurerm_mssql_server_extended_auditing_policy" "healthcare" {
  server_id                               = azurerm_mssql_server.healthcare.id
  storage_endpoint                        = azurerm_storage_account.sql_audit_logs.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.sql_audit_logs.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 90  # HIPAA minimum
  log_monitoring_enabled                  = true

  depends_on = [
    azurerm_storage_account.sql_audit_logs,
    azurerm_mssql_server.healthcare
  ]
}

# Role assignment for SQL managed identity to write to storage
resource "azurerm_role_assignment" "sql_audit_storage" {
  scope                = azurerm_storage_account.sql_audit_logs.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_mssql_server.healthcare.identity[0].principal_id
  
  depends_on = [
    azurerm_mssql_server.healthcare,
    azurerm_storage_account.sql_audit_logs
  ]
}
