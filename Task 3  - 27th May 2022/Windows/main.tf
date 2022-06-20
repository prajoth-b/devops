terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.7.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = ""
}

locals {
  resource_group = "win-rg"
  location       = "East Asia"
}


resource "azurerm_resource_group" "win_rg" {
  name     = local.resource_group
  location = local.location
}

resource "azurerm_virtual_network" "win_nw" {
  name                = "win-network"
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = azurerm_resource_group.win_rg.name

}

resource "azurerm_subnet" "win_sub" {
  name                 = "win-sub"
  resource_group_name  = local.resource_group
  virtual_network_name = azurerm_virtual_network.win_nw.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "win-vm-pip"
  resource_group_name = local.resource_group
  location            = local.location
  allocation_method   = "Dynamic"

  depends_on = [
    azurerm_resource_group.win_rg
  ]
}


resource "azurerm_network_interface" "win_nic" {
  name                = "win-nic"
  location            = local.location
  resource_group_name = local.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.win_sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  depends_on = [
    azurerm_virtual_network.win_nw
  ]
}

resource "azurerm_network_security_group" "win_nsg" {
  name                = "win-nsg"
  location            = local.location
  resource_group_name = local.resource_group

  security_rule {
    name                       = "IBA-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [
    azurerm_resource_group.win_rg
  ]
}

resource "azurerm_subnet_network_security_group_association" "win_nsg_sub" {
  subnet_id                 = azurerm_subnet.win_sub.id
  network_security_group_id = azurerm_network_security_group.win_nsg.id
}

resource "azurerm_windows_virtual_machine" "win_vm" {
  name                = "win-vm01"
  resource_group_name = local.resource_group
  location            = local.location
  size                = "Standard_DS1"
  admin_username      = "myusr"
  admin_password      = "-"
  network_interface_ids = [
    azurerm_network_interface.win_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.win_nic
  ]
}
