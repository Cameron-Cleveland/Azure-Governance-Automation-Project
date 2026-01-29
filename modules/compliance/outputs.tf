# modules/compliance/outputs.tf

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = azurerm_log_analytics_workspace.security.workspace_id
}

output "log_analytics_name" {
  description = "Log Analytics workspace name"
  value       = azurerm_log_analytics_workspace.security.name
}

output "action_group_id" {
  description = "Action group ID"
  value       = azurerm_monitor_action_group.security_alerts.id
}

output "subscription_id_used" {
  description = "Subscription ID used in the module"
  value       = var.subscription_id
}
