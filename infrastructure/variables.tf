locals {
  tags = merge(
    var.tags,
    {
      subscription   = data.azurerm_subscription.current.display_name,
      resource_group = var.resource_group.name
    }
  )
  # https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference?tabs=azurewebjobsstorage#connecting-to-host-storage-with-an-identity-preview
  host_storage_required_permissions = [
    "Storage Account Contributor", 
    "Storage Blob Data Owner", 
    "Storage Queue Data Contributor", 
    "Storage Table Data Contributor"
  ]
  # https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference?tabs=servicebus#connecting-to-host-storage-with-an-identity-preview
  servicebus_required_permissions = [
    "Azure Service Bus Data Sender", 
    "Azure Service Bus Data Receiver"
  ]
  function_app_keyvault_secrets = {
    for k,v in azurerm_key_vault_secret.this : upper(k) => "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.this.name};SecretName=${v.name})"
  }
  function_app_environments_variables = {
    for k,v in var.function_app_environments_variables : upper(k) => v
  }
  function_app_identity_connections = {
    SERVICEBUS_SENDER_CONNECTION__fullyQualifiedNamespace = "${var.service_bus.namespace_name}.servicebus.windows.net"
  }
  # function_app_ignore_changes = [
  #   app_settings["WEBSITE_RUN_FROM_PACKAGE"],
  #   tags["hidden-link: /app-insights-conn-string"],
  #   tags["hidden-link: /app-insights-instrumentation-key"],
  #   tags["hidden-link: /app-insights-resource-id"],
  # ]
}

data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

resource "random_integer" "storage_account_hash" {
  min = 100000
  max = 999999
}

variable "resource_group" {
  type = object({
    name = string, 
    location = string
  })
  default = {
    name     = "poc-serverless"
    location = "westus2"
  }
}

variable "keyvault" {
  type = object({
    name = string,
    sku_name = string,
    soft_delete_retention_days  = number,
    purge_protection_enabled    = bool,
    enable_rbac_authorization = bool,
  })
  default = {
    name = "poc-serverless-kv"
    sku_name = "standard"
    soft_delete_retention_days  = 7
    purge_protection_enabled    = false
    enable_rbac_authorization = true
  }
}

variable "storage_account" {
  type = object({
    name_prefix = string,
    account_kind = string,
    account_tier = string,
    account_replication_type = string
    release_container_name = string
  })
  default = {
    name_prefix = "pocserverlesshost"
    account_kind = "StorageV2"
    account_tier = "Standard"
    account_replication_type = "LRS"
    release_container_name = "releases"
  }
}

variable "service_plan" {
  type = object({
    name = string,
    os_type = string,
    sku_name = string,
  })
  default = {
    name = "poc-serverless-plan"
    os_type = "Linux"
    sku_name = "Y1"
  }
}

variable "log_analytics" {
  type = object({
    name = string,
    sku = string,
    retention_in_days = number,
  })
  default = {
    name = "poc-serverless-log"
    sku = "PerGB2018"
    retention_in_days = 30
  }
}

variable "application_insights" {
  type = object({
    name = string,
    application_type = string,
    retention_in_days = number,
  })
  default = {
    name = "poc-serverless-app"
    application_type = "web"
    retention_in_days = 30
  }
}

variable "function_app" {
  type = object({
    name = string,
    application_stack = object({
      python_version = number
    }),
  })
  default = {
    name = "poc-serverless-func"
    application_stack = {
      python_version = "3.7"
    }
  }
}

variable "function_app_source_path" {
  type = string
  default = "../serverless"
}

variable "function_app_environments_variables" {
    type = map(string)
  default = {
    env1 = "VALUE1"
    env2 = "VALUE2"
  }
}

variable "function_app_keyvault_secrets" {
  type = map(string)
  default = {
    mysecret1 = "FOO SECRET"
    mysecret2 = "BAR SECRET"
  }
}

variable "service_bus" {
  type = object({
    namespace_name = string,
    queue_name = string,
    sku = string,
  })
  default = {
    namespace_name = "poc-sb-serverless"
    queue_name = "poc-sbq-serverless"
    sku = "Standard"
  }
}

variable tags {
  type = map(string)
  default = {
    "environment" = "poc"
  }
}