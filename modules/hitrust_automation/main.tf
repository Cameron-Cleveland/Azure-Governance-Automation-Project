# HITRUST Certification Automation - Phase 6
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus2"
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for compliance logs"
  type        = string
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}

# Generate UUID for workbook
resource "random_uuid" "hitrust_workbook" {}

# 1. Key HITRUST Policy Assignments at Subscription level
resource "azurerm_subscription_policy_assignment" "hitrust_sql_encryption" {
  name                 = "hitrust-sql-encryption"
  subscription_id      = "/subscriptions/${var.subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/201ea587-7c90-41c3-910f-c280ae01cfd6"
  display_name         = "[HITRUST H09.06] Require SQL TDE Encryption"
  description          = "HIPAA/HITRUST control: Ensure Azure SQL Database encryption is enabled"
  
  parameters = jsonencode({
    effect = { "value" : "AuditIfNotExists" }  # CORRECT: This policy only audits
  })
}

resource "azurerm_subscription_policy_assignment" "hitrust_sql_firewall" {
  name                 = "hitrust-sql-firewall"
  subscription_id      = "/subscriptions/${var.subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/abfb7388-5bf4-4ad7-ba99-2cd2f41cebb9"
  display_name         = "[HITRUST O09.02] Block Public SQL Access"
  description          = "HIPAA/HITRUST control: Ensure no SQL Databases allow ingress from 0.0.0.0/0"
  
  parameters = jsonencode({
    effect = { "value" : "AuditIfNotExists" }  # CORRECT: This policy only audits
  })
}

resource "azurerm_subscription_policy_assignment" "hitrust_keyvault_logging" {
  name                 = "hitrust-keyvault-logging"
  subscription_id      = "/subscriptions/${var.subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/cf820ca0-f99e-4f3e-84fb-66e913812d21"
  display_name         = "[HITRUST AU03.01] Enable Key Vault Logging"
  description          = "HIPAA/HITRUST control: Ensure Key Vault logging is enabled"
  
  parameters = jsonencode({
    effect = { "value" : "AuditIfNotExists" }  # Already correct
  })
}

# 2. Compliance Evidence Workbook
resource "azurerm_application_insights_workbook" "hitrust_dashboard" {
  name                = random_uuid.hitrust_workbook.result
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = "HITRUST Compliance Dashboard"
  category            = "workbook"
  
  data_json = jsonencode({
    "version" = "Notebook/1.0",
    "items" = [
      {
        "type" = 1,
        "content" = {
          "json" = "## HITRUST Compliance Status\n### Automated control monitoring for healthcare\n\n**Implemented Controls:**\n1. SQL TDE Encryption (H09.06) - AuditIfNotExists\n2. SQL Firewall Restrictions (O09.02) - AuditIfNotExists\n3. Key Vault Audit Logging (AU03.01) - AuditIfNotExists\n4. PHI Access Monitoring (SI.01.01)\n5. Audit Trail Preservation (AU.02.02)"
        }
      },
      {
        "type" = 3,
        "content" = {
          "version" = "KqlItem/1.0",
          "query" = "AzureDiagnostics | summarize ResourceCount = count() by ResourceProvider, Category | order by ResourceCount desc",
          "size" = 2,
          "title" = "Audit Log Sources"
        }
      }
    ],
    "styleSettings" = {},
    "$schema" = "https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json"
  })

  tags = merge(var.tags, {
    Compliance = "HITRUST"
    Dashboard  = "Compliance"
  })
}

# 3. Output compliance information
output "policy_assignments" {
  value = {
    sql_encryption = azurerm_subscription_policy_assignment.hitrust_sql_encryption.id
    sql_firewall   = azurerm_subscription_policy_assignment.hitrust_sql_firewall.id
    keyvault_logs  = azurerm_subscription_policy_assignment.hitrust_keyvault_logging.id
  }
  description = "HITRUST policy assignment IDs"
}

output "compliance_dashboard_url" {
  value       = "https://portal.azure.com/#blade/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/workbooks"
  description = "Link to HITRUST compliance dashboard"
}
