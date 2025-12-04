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
  storage_account_name  = azurerm_storage_account.stg.name
  container_access_type = "private"
}

resource "azurerm_app_service_plan" "asp" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
  tags = var.tags
}

resource "azurerm_function_app" "name" {
  location                   = var.location
  name                       = var.function_app_name
  resource_group_name        = var.resource_group_name
  storage_account_name       = azurerm_storage_account.stg.name
  app_service_plan_id        = azurerm_app_service_plan.asp.id
  storage_account_access_key = azurerm_storage_account.stg.primary_access_key
  app_settings = {
    "AzureWebJobsStorage"             = azurerm_storage_account.stg.primary_connection_string
    "QR_CONTAINER"                    = var.storage_container_name
    "AZURE_STORAGE_CONNECTION_STRING" = azurerm_storage_account.stg.primary_connection_string
  }
  version = var.runtime_version
}