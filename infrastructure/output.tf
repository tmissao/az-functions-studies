output "resource_group" {
  value = {
    id = azurerm_resource_group.this.id
    name =  azurerm_resource_group.this.name
    location = azurerm_resource_group.this.location
  }
}

output "storage_account" {
  value = {
    id = azurerm_storage_account.this.id
    name =  azurerm_storage_account.this.name
    endpoint = azurerm_storage_account.this.primary_web_endpoint
  }
}

output "function_app" {
  value = {
    id = azurerm_linux_function_app.this.id
    name =  azurerm_linux_function_app.this.name
    app_settings = azurerm_linux_function_app.this.app_settings
  }
}

output "service_bus" {
  value = {
    id = azurerm_servicebus_namespace.this.id
    name = azurerm_servicebus_namespace.this.name
    fully_qualified_name = "${azurerm_servicebus_namespace.this.name}.servicebus.windows.net"
    queue = {
      id = azurerm_servicebus_queue.this.id
      name = azurerm_servicebus_queue.this.name
    }
  }
}