terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "3934322f-b747-4a01-b2bb-ff2df6f78675"
}

resource "azurerm_resource_group" "test" {
  name     = "rg-test-$(date +%s)"
  location = "eastus"
}

resource "azurerm_storage_account" "test" {
  name                     = "test$(date +%s)"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
