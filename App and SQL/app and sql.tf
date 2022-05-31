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

resource "azurerm_mssql_server" "sqlq12321312" {
  name                         = "sqlserver1355445"
  resource_group_name          = local.resource_group
  location                     = local.location
  version                      = "12.0"
  administrator_login          = "admina"
  administrator_login_password = "jnkvfa83ebn3j!"

  depends_on = [
    azurerm_resource_group.win_rg
  ]
}

resource "azurerm_mssql_database" "mydb" {
  name      = "mydb01"
  server_id = azurerm_mssql_server.sqlq12321312.id

  depends_on = [
    azurerm_mssql_server.sqlq12321312, azurerm_resource_group.win_rg
  ]
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



resource "azurerm_mssql_firewall_rule" "db_firewall_rule" {
  name             = "firewall-rule"
  server_id        = azurerm_mssql_server.sqlq12321312.id
  start_ip_address = "103.219.166.226"
  end_ip_address   = "103.219.166.226"
}


