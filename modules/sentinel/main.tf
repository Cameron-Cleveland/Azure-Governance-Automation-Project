# modules/sentinel/main.tf - Advanced Monitoring & Sentinel

# 1. Healthcare-specific detection rules
resource "azurerm_sentinel_alert_rule_scheduled" "phi_unusual_access" {
  name                       = "PHI Unusual Access Patterns"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  display_name               = "Unusual PHI Access Patterns"
  description                = "Detects unusual access to PHI data"
  severity                   = "Medium"
  enabled                    = true
  query                      = <<QUERY
SecurityEvent
| where TimeGenerated > ago(1h)
| where EventID in (4624, 4625, 4634)
| where Account contains "@"
| summarize EventCount = count() by Account, EventID, bin(TimeGenerated, 15m)
| where EventCount > 5
QUERY

  query_frequency            = "PT1H"
  query_period               = "PT1H"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 1

  tactics = ["Collection"]
}

resource "azurerm_sentinel_alert_rule_scheduled" "phi_bulk_extraction" {
  name                       = "PHI Bulk Data Extraction"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  display_name               = "Bulk Data Extraction Detection"
  description                = "Detects potential data exfiltration"
  severity                   = "High"
  enabled                    = true
  query                      = <<QUERY
SecurityEvent
| where TimeGenerated > ago(30m)
| where EventID in (4688, 1, 4104)
| where CommandLine has_any("copy", "move", "export", "download", "upload")
| summarize ProcessCount = count() by Computer, CommandLine, bin(TimeGenerated, 5m)
| where ProcessCount > 3
QUERY

  query_frequency            = "PT30M"
  query_period               = "PT30M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 1

  tactics = ["Exfiltration"]
}
