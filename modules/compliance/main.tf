data "azurerm_subscription" "current" {
  subscription_id = var.subscription_id
}

# 2. Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "security" {
  name                = "la-security-${replace(var.resource_group_name, "/[^a-zA-Z0-9]/", "")}"
  location            = "eastus2"
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
  tags = var.tags
}

# 3. Create Action Group
resource "azurerm_monitor_action_group" "security_alerts" {
  name                = "ag-security-${var.resource_group_name}"
  resource_group_name = var.resource_group_name
  short_name          = "secalert"
  location            = "eastus2"

  email_receiver {
    name                    = "security-admin"
    email_address           = "security@example.com"
    use_common_alert_schema = true
  }

  tags = var.tags
}
