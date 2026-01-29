resource "azurerm_virtual_network" "healthcare_vnet" {
  name                = "vnet-${var.project_name}-${var.environment}"
  location            = "eastus2"
  resource_group_name = var.resource_group_name
  address_space       = ["10.100.0.0/16"]
  
  tags = var.tags
}

# Subnets with healthcare segmentation
resource "azurerm_subnet" "public" {
  name                 = "snet-public"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.healthcare_vnet.name
  address_prefixes     = ["10.100.1.0/24"]
  
  # Enable service endpoints for private access
  service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

resource "azurerm_subnet" "private" {
  name                 = "snet-private"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.healthcare_vnet.name
  address_prefixes     = ["10.100.2.0/24"]
  
  service_endpoints = ["Microsoft.Sql", "Microsoft.KeyVault"]
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.healthcare_vnet.name
  address_prefixes     = ["10.100.3.0/24"]
  
  # Private endpoints will go here (HIPAA requirement)
  private_endpoint_network_policies_enabled = true
}

# Network Security Groups (Healthcare specific rules)
resource "azurerm_network_security_group" "healthcare_nsg" {
  name                = "nsg-${var.project_name}"
  location            = "eastus2"
  resource_group_name = var.resource_group_name
  
  # HIPAA: Restrict RDP/SSH access
  security_rule {
    name                       = "Deny-RDP-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "Deny-SSH-Inbound"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  # Allow HTTPS for healthcare applications
  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  tags = var.tags
}

# Associate NSG with subnets
resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.healthcare_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.healthcare_nsg.id
}

# Private DNS Zones for Private Endpoints (HIPAA requirement)
resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "sql_server" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "storage_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Link DNS Zones to VNet (required for name resolution)
resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "vnet-link-kv-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = azurerm_virtual_network.healthcare_vnet.id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_server" {
  name                  = "vnet-link-sql-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql_server.name
  virtual_network_id    = azurerm_virtual_network.healthcare_vnet.id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob" {
  name                  = "vnet-link-storage-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob.name
  virtual_network_id    = azurerm_virtual_network.healthcare_vnet.id
  registration_enabled  = false
  tags                  = var.tags
}
