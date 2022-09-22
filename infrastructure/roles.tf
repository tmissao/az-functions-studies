resource "azurerm_user_assigned_identity" "function_app" {
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name = var.function_app.name
}

resource "azurerm_role_assignment" "usermanagedidentity_functionapp_kv" {
  for_each = toset(["Key Vault Secrets User"])
  scope                = azurerm_key_vault.this.id
  role_definition_name = each.key
  principal_id         = azurerm_user_assigned_identity.function_app.principal_id
}

resource "azurerm_role_assignment" "roleassignment_functionapp_servicebus" {
  for_each = toset(local.servicebus_required_permissions)
  scope                = azurerm_servicebus_queue.this.id
  role_definition_name = each.key
  principal_id         = azurerm_linux_function_app.this.identity.0.principal_id
}

resource "azurerm_role_assignment" "current_user_kv" {
  for_each = toset(["Key Vault Administrator", "Owner"])
  scope                = azurerm_key_vault.this.id
  role_definition_name = each.key
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "current_user_servicebus" {
  for_each = toset(local.servicebus_required_permissions)
  scope                = azurerm_servicebus_queue.this.id
  role_definition_name = each.key
  principal_id         = data.azurerm_client_config.current.object_id
}