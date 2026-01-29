variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "eastus2"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "177"
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "healthsec"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "Healthcare Security Platform"
    Environment = "Development"
    ManagedBy   = "Terraform"
    Compliance  = "HIPAA-HITRUST"
  }
}
variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID for private endpoints"
  type        = string
}

variable "virtual_network_id" {
  description = "Virtual Network ID for Private Endpoints"
  type        = string
}

variable "aad_admin_name" {
  description = "Azure AD admin name for SQL"
  type        = string
  default     = "sql-admin"
}

variable "aad_admin_object_id" {
  description = "Azure AD admin object ID"
  type        = string
  default     = ""
}
