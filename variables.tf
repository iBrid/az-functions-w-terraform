variable "resource_group_name" {
  type    = string
  default = "azfctn-rg"
}

variable "location" {
  type    = string
  default = "West US 3"
}

variable "storage_account_name" {
  type    = string
  default = "azfctn-storageacct0224"
}

variable "storage_container_name" {
  type    = string
  default = "azfctn-container"
}

variable "function_app_name" {
  type    = string
  default = "azfctn-app0224"
}

variable "app_service_plan_name" {
  type    = string
  default = "azfctn-appserviceplan0224"
}

variable "app_service_plan_sku" {
  type    = string
  default = "Y1" # Y1 is the SKU for the Consumption plan
}

variable "runtime_stack" {
  type    = string
  default = "python"
}

variable "runtime_version" {
  type    = string
  default = "~3"
}

variable "function_app_settings" {
  type = map(string)
  default = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    "Environment" = "Development"
    "Project"     = "AzureFunctionApp"
  }
}

