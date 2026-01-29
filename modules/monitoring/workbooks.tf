# Generate UUIDs for workbooks (required by Azure)
resource "random_uuid" "healthcare_security_workbook" {}
resource "random_uuid" "vulnerability_management_workbook" {}

# Get current subscription data
data "azurerm_subscription" "current" {}

# Azure Monitor Workbooks for Healthcare Monitoring
resource "azurerm_application_insights_workbook" "healthcare_security" {
  name                = random_uuid.healthcare_security_workbook.result
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = "Healthcare Security Monitoring Dashboard"
  category            = "workbook"
  
  data_json = jsonencode({
    "version" = "Notebook/1.0",
    "items" = [
      {
        "type" = 1,
        "content" = {
          "json" = "## Healthcare Security Monitoring Dashboard\n### Real-time monitoring of PHI access and security events"
        }
      },
      {
        "type" = 3,
        "content" = {
          "version" = "KqlItem/1.0",
          "query" = "AzureDiagnostics | where ResourceGroup == '${var.resource_group_name}' | where ResourceProvider == 'MICROSOFT.SQL' | where Category == 'SQLSecurityAuditEvents' | summarize PHI_Access=countif(statement has_any('Patient', 'Medical', 'Record')) by bin(TimeGenerated, 1h) | render timechart",
          "size" = 2,
          "title" = "PHI Access Patterns"
        }
      }
    ],
    "styleSettings" = {},
    "$schema" = "https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json"
  })

  tags = merge(var.tags, {
    "Dashboard"   = "Security",
    "Compliance"  = "HIPAA",
    "Environment" = var.environment
  })
}

resource "azurerm_application_insights_workbook" "vulnerability_management" {
  name                = random_uuid.vulnerability_management_workbook.result
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = "Healthcare Vulnerability Management"
  category            = "workbook"
  
  data_json = jsonencode({
    "version" = "Notebook/1.0",
    "items" = [
      {
        "type" = 1,
        "content" = {
          "json" = "## Vulnerability Management Dashboard\n### Track and manage security vulnerabilities across healthcare environment"
        }
      },
      {
        "type" = 3,
        "content" = {
          "version" = "KqlItem/1.0",
          "query" = "SecurityRecommendation | where ResourceGroup == '${var.resource_group_name}' | where RecommendationState == 'Active' | summarize by RecommendationSeverity | order by RecommendationSeverity desc",
          "size" = 2,
          "title" = "Active Vulnerabilities by Severity"
        }
      }
    ],
    "styleSettings" = {},
    "$schema" = "https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json"
  })

  tags = merge(var.tags, {
    "Dashboard"   = "Vulnerability",
    "Compliance"  = "HITRUST",
    "Environment" = var.environment
  })
}
