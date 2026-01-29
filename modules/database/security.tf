# Firewall rules
resource "azurerm_mssql_firewall_rule" "deny_all" {
  name             = "DenyAll"
  server_id        = azurerm_mssql_server.healthcare.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.healthcare.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# RBAC assignments
resource "azurerm_role_assignment" "break_glass_sql_admin" {
  scope                = azurerm_mssql_server.healthcare.id
  role_definition_name = "SQL Security Manager"
  principal_id         = var.entra_break_glass_group_id
}

resource "azurerm_role_assignment" "data_access_sql_contributor" {
  scope                = azurerm_mssql_database.patient_records.id
  role_definition_name = "SQL DB Contributor"
  principal_id         = var.entra_data_access_group_id
}

resource "azurerm_role_assignment" "auditors_sql_reader" {
  scope                = azurerm_mssql_database.patient_records.id
  role_definition_name = "SQL Security Manager"
  principal_id         = var.entra_auditor_group_id
}
