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

  subscription_id = "b014852b-efd9-48da-8b49-c6ac117f61f9"
}

locals {
  resource_group = "terraform-rg"
  location       = "East Asia"
}


resource "azurerm_resource_group" "win_rg" {
  name     = local.resource_group
  location = local.location
}

resource "azurerm_service_plan" "appln" {
  name                = "az-appln"
  resource_group_name = local.resource_group
  location            = local.location
  os_type             = "Linux"
  sku_name            = "B1"
  depends_on = [
    azurerm_resource_group.win_rg
  ]
}

resource "azurerm_linux_web_app" "example" {
  name                = "az-app"
  resource_group_name = local.resource_group
  location            = local.location
  service_plan_id     = azurerm_service_plan.appln.id

  depends_on = [
    azurerm_resource_group.win_rg
  ]

  site_config {
    linux_fx_version = "TOMCAT|10-java11"
  }
}
