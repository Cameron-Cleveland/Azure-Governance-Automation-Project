variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault ID for storing secrets"
  type        = string
}

variable "key_vault_access_policy_id" {
  description = "Key Vault access policy ID for dependency management"
  type        = string
  default     = ""
}

variable "entra_break_glass_group_id" {
  description = "Entra ID break glass group object ID"
  type        = string
}

variable "entra_data_access_group_id" {
  description = "Entra ID data access group object ID"
  type        = string
}

variable "entra_auditor_group_id" {
  description = "Entra ID auditor group object ID"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID for SQL private endpoint"
  type        = string
}

variable "audit_storage_endpoint" {
  description = "Storage endpoint for audit logs"
  type        = string
  default     = ""
}

variable "audit_storage_key" {
  description = "Storage key for audit logs"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}

variable "private_dns_zone_ids" {
  description = "List of private DNS zone IDs for private endpoint"
  type        = list(string)
  default     = []
}

variable "aad_admin_name" {
  description = "Azure AD admin name for SQL"
  type        = string
  default     = ""
}

variable "aad_admin_object_id" {
  description = "Azure AD admin object ID"
  type        = string
  default     = ""
}

variable "sql_managed_identity_id" {
  description = "Managed Identity ID for SQL Server"
  type        = string
  default     = ""
}

variable "sql_server_name" {
  description = "SQL Server name. Defaults to sql-hc-{environment} based on environment variable."
  type        = string
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for audit log diagnostics"
  type        = string
  default     = ""
}

variable "create_sample_database" {
  description = "Create sample PatientRecords database"
  type        = bool
  default     = true
}

