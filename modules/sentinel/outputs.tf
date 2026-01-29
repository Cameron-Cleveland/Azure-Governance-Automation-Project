output "sentinel_analytics_rules" {
  value = {
    phi_unusual_access = azurerm_sentinel_alert_rule_scheduled.phi_unusual_access.id
    phi_bulk_extraction = azurerm_sentinel_alert_rule_scheduled.phi_bulk_extraction.id
  }
  description = "Sentinel analytics rule IDs for PHI monitoring"
}

output "sentinel_configured" {
  value = true
  description = "Sentinel analytics rules configured for healthcare"
}
