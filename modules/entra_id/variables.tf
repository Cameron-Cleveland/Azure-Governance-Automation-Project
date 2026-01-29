variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID for RBAC assignments"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}