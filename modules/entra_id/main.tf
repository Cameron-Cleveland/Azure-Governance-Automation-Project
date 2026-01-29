terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.45"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

data "azuread_client_config" "current" {}

# Healthcare Access Groups
resource "azuread_group" "hc_break_glass" {
  display_name     = "HC-BreakGlass-Admins-${var.environment}"
  security_enabled = true
  description      = "Emergency access for healthcare incidents"
  owners           = [data.azuread_client_config.current.object_id]
  
  lifecycle {
    prevent_destroy = true  # Critical security group
  }
}

resource "azuread_group" "hc_data_access" {
  display_name     = "HC-Data-Access-${var.environment}"
  security_enabled = true
  description      = "Access to PHI data - requires MFA"
  owners           = [data.azuread_client_config.current.object_id]
}

resource "azuread_group" "hc_auditors" {
  display_name     = "HC-Auditors-${var.environment}"
  security_enabled = true
  description      = "Read-only access for compliance audits"
  owners           = [data.azuread_client_config.current.object_id]
}

# PIM Simulation with time-based access
resource "time_rotating" "emergency_access_rotation" {
  rotation_days = 1  # Rotate daily for demo
}

# Simulate JIT (Just-In-Time) access
resource "azurerm_role_assignment" "break_glass_sql" {
  count = var.environment == "prod" ? 1 : 0
  
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Security Reader"
  principal_id         = azuread_group.hc_break_glass.object_id
  
  # Add lifecycle to simulate temporary access
  lifecycle {
    # In production, this would be managed by PIM
    # For demo, we'll keep it permanent but documented
  }
}

# Output for demo script
output "break_glass_group_id" {
  value       = azuread_group.hc_break_glass.id
  description = "Break glass admin group ID"
  sensitive   = false
}

output "data_access_group_id" {
  value       = azuread_group.hc_data_access.id
  description = "PHI data access group ID"
  sensitive   = false
}

output "auditor_group_id" {
  value       = azuread_group.hc_auditors.id
  description = "Auditor group ID"
  sensitive   = false
}
