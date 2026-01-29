variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "key_vault_id" {
  description = "ID of the Key Vault for audit logging"
  type        = string
}

variable "soc_email" {
  description = "SOC team email for alerts"
  type        = string
  default     = "soc@example.com"
}

variable "pagerduty_webhook" {
  description = "PagerDuty webhook URL"
  type        = string
  default     = "https://events.pagerduty.com/v2/enqueue"
}

variable "storage_account_id" {
  description = "ID of storage account for audit logging"
  type        = string
}
variable "sql_server_id" {
  description = "SQL Server resource ID for diagnostic settings"
  type        = string
  default     = ""
}


variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}
