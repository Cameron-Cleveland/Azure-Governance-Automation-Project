# modules/monitoring/main.tf - WORKING VERSION

# 1. Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "healthcare" {
  name                = "log-${var.project_name}-${var.environment}"
  location            = "eastus2"
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 365
  
  tags = merge(var.tags, {
    Compliance = "HIPAA-164.312(b)"
  })
}

# 2. Microsoft Sentinel SOLUTION (but not rules yet)
resource "azurerm_log_analytics_solution" "sentinel" {
  solution_name         = "SecurityInsights"
  location              = "eastus2"
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.healthcare.id
  workspace_name        = azurerm_log_analytics_workspace.healthcare.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
}

# 3. Diagnostic Settings for Key Vault
resource "azurerm_monitor_diagnostic_setting" "key_vault_audit" {
  name               = "keyvault-audit-logs"
  target_resource_id = var.key_vault_id
  
  log_analytics_workspace_id = azurerm_log_analytics_workspace.healthcare.id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# 4. Action Group
resource "azurerm_monitor_action_group" "soc_alerts" {
  name                = "SOC-Healthcare-Alerts"
  resource_group_name = var.resource_group_name
  short_name          = "SOCAlert"

  email_receiver {
    name          = "Healthcare-SOC"
    email_address = var.soc_email
  }
  
  tags = var.tags
}

# 5. SIMPLIFIED Storage Diagnostic
resource "azurerm_monitor_diagnostic_setting" "storage_audit" {
  name               = "storage-audit-logs"
  target_resource_id = var.storage_account_id
  
  log_analytics_workspace_id = azurerm_log_analytics_workspace.healthcare.id
  
  # Minimal working configuration
  metric {
    category = "Transaction"
    enabled  = true
  }
}

# 6. Defender for Cloud - ONLY VirtualMachines (most reliable)
resource "azurerm_security_center_subscription_pricing" "defender_vms" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
}

# 7. SQL Server Audit to Log Analytics (if SQL exists)
