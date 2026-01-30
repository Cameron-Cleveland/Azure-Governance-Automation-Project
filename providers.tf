terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85"
    }
    # ADDED: Requirement for AzureAD provider
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
  use_cli                    = false
  skip_provider_registration = true
}

# ADDED: Explicit configuration for AzureAD
provider "azuread" {
  # This will automatically use the same ARM_ credentials as azurerm
}