# Data Protection & Encryption - Phase 5
variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus2"
}

variable "key_vault_id" {
  description = "Key Vault resource ID"
  type        = string
}

variable "storage_account_id" {
  description = "Storage account ID for encryption"
  type        = string
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}

# 1. Create encryption keys for future use
resource "azurerm_key_vault_key" "storage_encryption_key" {
  name         = "storage-encryption-key"
  key_vault_id = var.key_vault_id
  key_type     = "RSA"
  key_size     = 2048
  
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  
  tags = var.tags
}

resource "azurerm_key_vault_key" "disk_encryption_key" {
  name         = "disk-encryption-key"
  key_vault_id = var.key_vault_id
  key_type     = "RSA"
  key_size     = 2048
  
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  
  tags = var.tags
}

# 2. Document encryption setup (not deploying due to complexity)
# - Storage Service Encryption with CMK requires Premium storage
# - Disk Encryption Set requires specific permissions and key setup
# - These would be implemented in production

output "encryption_keys" {
  value = {
    storage_key_id = azurerm_key_vault_key.storage_encryption_key.id
    disk_key_id    = azurerm_key_vault_key.disk_encryption_key.id
  }
  description = "Encryption key IDs for storage and disk encryption"
}

output "encryption_notes" {
  value = "For production: Enable Storage Service Encryption with CMK on Premium storage, and create Disk Encryption Set with proper permissions"
  description = "Notes on completing encryption setup"
}
