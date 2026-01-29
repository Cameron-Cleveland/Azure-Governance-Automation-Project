output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "log_analytics_workspace_id" {
  value       = module.monitoring.log_analytics_workspace_id
  description = "ID of Log Analytics workspace for querying logs"
}

output "sentinel_workspace_url" {
  value       = "https://portal.azure.com/#blade/Microsoft_Azure_Security_Insights/WorkspaceSelectorBlade"
  description = "URL to access Microsoft Sentinel"
}

output "defender_dashboard_url" {
  value       = "https://portal.azure.com/#blade/Microsoft_Azure_Security/SecurityMenuBlade/0"
  description = "URL to Microsoft Defender for Cloud dashboard"
}