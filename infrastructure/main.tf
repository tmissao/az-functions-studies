resource "azurerm_resource_group" "this" {
  name     = var.resource_group.name
  location = var.resource_group.location
  tags     = local.tags
}

resource "azurerm_key_vault" "this" {
  name                        = var.keyvault.name
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = var.keyvault.soft_delete_retention_days
  purge_protection_enabled    = var.keyvault.purge_protection_enabled
  sku_name = var.keyvault.sku_name
  enable_rbac_authorization = var.keyvault.enable_rbac_authorization
  tags = local.tags
}

resource "azurerm_key_vault_secret" "this" {
  for_each = var.function_app_keyvault_secrets
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.this.id
  depends_on = [
    azurerm_role_assignment.current_user_kv
  ]
}

resource "azurerm_storage_account" "this" {
  name                     = "${var.storage_account.name_prefix}${random_integer.storage_account_hash.result}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_kind = var.storage_account.account_kind
  account_tier             = var.storage_account.account_tier
  account_replication_type = var.storage_account.account_replication_type
  tags = local.tags
}

resource "azurerm_service_plan" "this" {
  name                = var.service_plan.name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = var.service_plan.os_type
  sku_name = var.service_plan.sku_name 
  tags = local.tags
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = var.log_analytics.name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.log_analytics.sku
  retention_in_days   = var.log_analytics.retention_in_days
  tags = local.tags
}

resource "azurerm_application_insights" "this" {
  name                = var.application_insights.name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = var.application_insights.application_type
  retention_in_days = var.application_insights.retention_in_days
  tags = local.tags
}

resource "azurerm_linux_function_app" "this" {
  name                = var.function_app.name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  storage_account_name       = azurerm_storage_account.this.name
  service_plan_id            = azurerm_service_plan.this.id
  key_vault_reference_identity_id = azurerm_user_assigned_identity.function_app.id
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  site_config {
    application_insights_key = azurerm_application_insights.this.instrumentation_key
    application_stack {
      python_version = var.function_app.application_stack.python_version
    }
  }
  app_settings = merge(
    local.function_app_keyvault_secrets,
    local.function_app_environments_variables,
    local.function_app_identity_connections
  )
  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.function_app.id]
  }
  tags = local.tags
  depends_on = [
    azurerm_user_assigned_identity.function_app,
    azurerm_role_assignment.usermanagedidentity_functionapp_kv,
  ]
  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"]
    ]
  }
}

resource "azurerm_servicebus_namespace" "this" {
  name                = var.service_bus.namespace_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.service_bus.sku
  tags = local.tags
}

resource "azurerm_servicebus_queue" "this" {
  name         = var.service_bus.queue_name
  namespace_id = azurerm_servicebus_namespace.this.id
}