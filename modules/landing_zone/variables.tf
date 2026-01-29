variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "root_management_group_id" {
  description = "Root management group ID"
  type        = string
  default     = "healthcare-org"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}
