variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

# Make this optional with a default value
variable "action_group_id" {
  description = "ID of action group for alerts (optional)"
  type        = string
  default     = ""  # Default to empty string
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}  # Add default empty map
}
