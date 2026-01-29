terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# Generate secure SQL admin password (AWS RDS master password)
resource "random_password" "sql_admin" {
  length           = 24
  special          = true
  override_special = "!@#$%^&*()-_=+[]{}|;:,.<>?"
  min_special      = 4
  min_numeric      = 4
  min_upper        = 4
  min_lower        = 4
}

# Store password in Key Vault (AWS Secrets Manager)
resource "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password-${var.environment}"
  value        = random_password.sql_admin.result
  key_vault_id = var.key_vault_id
  content_type = "password"
  
  tags = merge(var.tags, {
    compliance = "hipaa"
    sensitive  = "true"
  })

  depends_on = [var.key_vault_access_policy_id]
}

# SQL Server (AWS RDS-style with username/password)
resource "azurerm_mssql_server" "healthcare" {
    name                         = var.sql_server_name != "" ? var.sql_server_name : "sql-hc-${var.environment}"
  resource_group_name          = var.resource_group_name
  location            = "eastus2"
  version                      = "12.0"
  administrator_login          = "sqladmin"                     # AWS: master username
  administrator_login_password = random_password.sql_admin.result # AWS: master password
  minimum_tls_version          = "1.2"

  # Optional Azure AD admin for break-glass
  dynamic "azuread_administrator" {
    for_each = var.aad_admin_object_id != "" ? [1] : []
    content {
      login_username = var.aad_admin_name != "" ? var.aad_admin_name : "azuread-admin"
      object_id      = var.aad_admin_object_id
    }
  }

  # Managed Identity for connections (optional)
  dynamic "identity" {
    for_each = var.sql_managed_identity_id != "" ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = [var.sql_managed_identity_id]
    }
  }

  # Fallback: System-assigned identity if no user-assigned
  dynamic "identity" {
    for_each = var.sql_managed_identity_id == "" ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  tags = var.tags
}

# Database
resource "azurerm_mssql_database" "patient_records" {
  name        = "PatientRecords"
  server_id   = azurerm_mssql_server.healthcare.id
  sku_name    = "GP_Gen5_2"
  max_size_gb = 32
  
  transparent_data_encryption_enabled = true
  
  short_term_retention_policy {
    retention_days = 35
  }
  
  tags = var.tags
}

# Private Endpoint
resource "azurerm_private_endpoint" "sql" {
  name                = "pe-sql-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = "eastus2"
  subnet_id           = var.private_subnet_id
  
  private_service_connection {
    name                           = "psc-sql-${var.environment}"
    private_connection_resource_id = azurerm_mssql_server.healthcare.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
  
  private_dns_zone_group {
    name                 = "sql-dns-zone-group"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags
}

data "azurerm_client_config" "current" {}
