# modules/monitoring/outputs.tf
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.healthcare.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.healthcare.name
}

output "sentinel_workspace_id" {
  description = "ID of the Sentinel workspace"
  value       = azurerm_log_analytics_solution.sentinel.id
}

output "action_group_id" {
  description = "ID of the SOC alerts action group"
  value       = azurerm_monitor_action_group.soc_alerts.id
}

output "action_group_name" {
  description = "Name of the SOC alerts action group"
  value       = azurerm_monitor_action_group.soc_alerts.name
}
output "workbook_ids" {
  value = {
    healthcare_security    = azurerm_application_insights_workbook.healthcare_security.id
    vulnerability_management = azurerm_application_insights_workbook.vulnerability_management.id
  }
  description = "Azure Monitor workbook IDs"
}

output "workbooks_configured" {
  value = true
  description = "Healthcare monitoring workbooks configured"
}
