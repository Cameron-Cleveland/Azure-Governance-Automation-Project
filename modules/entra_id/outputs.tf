output "break_glass_group_name" {
  value       = azuread_group.hc_break_glass.display_name
  description = "Break glass admin group display name"
}

output "data_access_group_name" {
  value       = azuread_group.hc_data_access.display_name
  description = "PHI data access group display name"
}

output "auditor_group_name" {
  value       = azuread_group.hc_auditors.display_name
  description = "Auditor group display name"
}

output "all_group_ids" {
  value = {
    break_glass = azuread_group.hc_break_glass.id
    data_access = azuread_group.hc_data_access.id
    auditors    = azuread_group.hc_auditors.id
  }
  description = "All Entra ID group IDs"
  sensitive   = true
}

output "environment" {
  value       = var.environment
  description = "Environment name"
}
