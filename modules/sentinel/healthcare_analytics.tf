# Healthcare-specific detection rules
resource "azurerm_sentinel_alert_rule_scheduled" "phi_access_anomaly" {
  name                       = "PHI Access Anomaly Detection"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  display_name               = "Unusual Authentication Patterns"
  severity                   = "High"
  query                      = <<QUERY
SecurityEvent
| where TimeGenerated > ago(30m)
| where EventID == 4624
| where AccountType == "User"
| summarize LoginCount = count() by Account, Computer, bin(TimeGenerated, 10m)
| where LoginCount > 3
QUERY
  
  query_frequency = "PT15M"
  query_period    = "PT30M"
}
