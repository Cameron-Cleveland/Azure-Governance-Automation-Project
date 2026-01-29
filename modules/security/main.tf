terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85"
    }
  }
}

data "azurerm_client_config" "current" {}

# Key Vault access policy for Terraform service principal
resource "azurerm_key_vault_access_policy" "terraform_sp" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  
  # ALL key permissions needed for key management including rotation
  key_permissions = [
    "Get", "List", "Create", "Delete", "Recover", "Backup", "Restore",
    "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Verify", "Sign", "Purge",
    "GetRotationPolicy", "SetRotationPolicy", "Rotate"
  ]
  
  # ALL secret permissions
  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"
  ]
}

# Output the policy ID for dependencies
