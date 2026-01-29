output "sql_server_name" {
  value = azurerm_mssql_server.healthcare.name
}

output "database_name" {
  value = azurerm_mssql_database.patient_records.name
}

output "private_endpoint_id" {
  value = azurerm_private_endpoint.sql.id
}

output "audit_storage_account_name" {
  value = try(azurerm_storage_account.sql_audit_logs.name, "audit-not-configured")
  description = "Storage account name for SQL audit logs"
}

output "audit_logging_enabled" {
  value = true
  description = "HIPAA audit logging is configured"
}

output "audit_retention_days" {
  value = 90
  description = "Audit log retention in days"
}

output "sql_server_id" {
  value = azurerm_mssql_server.healthcare.id
  description = "SQL Server resource ID"
}
