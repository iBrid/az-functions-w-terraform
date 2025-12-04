resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "stg" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

resource "azurerm_storage_container" "container" {
  name                  = var.storage_container_name
  storage_account_name  = var.storage_account_name
  container_access_type = "private"
}

resource "azurerm_app_service" "appservice" {
    name                = var.app_service_plan_name
    location            = var.location
    resource_group_name = var.resource_group_name
    app_service_plan_id = var.app_service_plan_name.id
    tags                = var.tags
}

resource "azurerm_function_app" "name" {
  location =  var.location
  name = var.function_app_name
  resource_group_name = var.resource_group_name
  storage_account_name = var.storage_account_name
  app_service_plan_id = var.app_service_plan_name.id
  storage_account_access_key = azurerm_storage_account.stg.primary_access_key
  version = var.runtime_version
}