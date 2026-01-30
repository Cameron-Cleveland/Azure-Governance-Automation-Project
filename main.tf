# AZURE HEALTHCARE SECURITY PLATFORM
# Complete 6-Phase Implementation

# ============================================
# PHASE 1: LANDING ZONE & GOVERNANCE
# ============================================
module "landing_zone" {
  source = "./modules/landing_zone"

  subscription_id = data.azurerm_subscription.current.subscription_id
  environment     = var.environment
  tags            = var.tags
}

# ============================================
# CORE INFRASTRUCTURE
# ============================================
resource "azurerm_resource_group" "main" {
  name     = "rg-hc-lab-177"
  location = "eastus2"
  tags     = var.tags
}

resource "azurerm_storage_account" "tfstate" {
  name                              = "sthc177"
  resource_group_name               = "rg-hc-lab-177"
  location                          = azurerm_resource_group.main.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  infrastructure_encryption_enabled = true
  tags                              = var.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

# Key Vault MUST be created BEFORE modules that reference it
resource "azurerm_key_vault" "healthcare" {
  name                = "kv-hc-177"
  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus2"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  
  # DISABLE soft delete and purge protection for labs
  soft_delete_retention_days = 90   # Minimum, not 90
  purge_protection_enabled   = true  # Disable purge protection

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

# ============================================
# MODULES DEPLOYMENT (Phases 3-6)
# ============================================

# 1. NETWORKING FIRST
module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus2"
  project_name        = var.project_name
  environment         = var.environment
  tags                = var.tags
}

# 2. ENTRA ID SECOND
module "entra_id" {
  source = "./modules/entra_id"

  environment     = var.environment
  subscription_id = data.azurerm_subscription.current.subscription_id
  tags            = var.tags
}

# 3. SECURITY THIRD
module "security" {
  source = "./modules/security"

  key_vault_id        = azurerm_key_vault.healthcare.id
  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus2"
  environment         = var.environment
  tags                = var.tags
}

# 4. DATABASE FOURTH
module "database" {
  source = "./modules/database"

  resource_group_name        = azurerm_resource_group.main.name
  location                   = "eastus2"
  environment                = var.environment
  key_vault_id               = azurerm_key_vault.healthcare.id
  key_vault_access_policy_id = module.security.key_vault_access_policy_id

  private_subnet_id      = module.networking.data_subnet_id
  private_dns_zone_ids   = [module.networking.sql_private_dns_zone_id]

  entra_break_glass_group_id = module.entra_id.break_glass_group_id
  entra_data_access_group_id = module.entra_id.data_access_group_id
  entra_auditor_group_id     = module.entra_id.auditor_group_id
  aad_admin_name             = var.aad_admin_name
  aad_admin_object_id        = var.aad_admin_object_id

  tags = var.tags

  depends_on = [
    module.security,
    module.networking,
    module.entra_id
  ]
}

# 5. MONITORING FIFTH
module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus2"
  project_name        = var.project_name
  environment         = var.environment
  tags                = var.tags
  key_vault_id        = azurerm_key_vault.healthcare.id
  storage_account_id  = azurerm_storage_account.tfstate.id
  soc_email           = "admin@example.com"
  subscription_id     = data.azurerm_subscription.current.subscription_id

  # SQL Server diagnostics
  sql_server_id = module.database.sql_server_id

  depends_on = [module.database]
}

# 6. DATA PROTECTION (Phase 5)
module "data_protection" {
  source = "./modules/data_protection"

  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus2"
  key_vault_id        = azurerm_key_vault.healthcare.id
  storage_account_id  = azurerm_storage_account.tfstate.id
  tags                = var.tags

  depends_on = [
    module.security,
    module.monitoring
  ]
}

# 7. SENTINEL ANALYTICS RULES (Phase 4)
module "sentinel" {
  source = "./modules/sentinel"

  log_analytics_workspace_id   = module.monitoring.log_analytics_workspace_id
  resource_group_name          = azurerm_resource_group.main.name   
  location                     = "eastus2"
  tags                         = var.tags

  depends_on = [module.monitoring]
}

# 8. COMPLIANCE SIXTH
module "compliance" {
  source = "./modules/compliance"

  subscription_id     = data.azurerm_subscription.current.subscription_id
  location            = "eastus2"
  resource_group_name = azurerm_resource_group.main.name
  action_group_id     = ""
  tags                = var.tags

  depends_on = [module.monitoring]
}

# 9. HITRUST CERTIFICATION AUTOMATION (Phase 6)
module "hitrust_automation" {
  source = "./modules/hitrust_automation"

  subscription_id            = data.azurerm_subscription.current.subscription_id
  resource_group_name       = azurerm_resource_group.main.name
  location                  = "eastus2"
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                      = var.tags

  depends_on = [
    module.data_protection,
    module.compliance
  ]
}
