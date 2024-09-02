
resource "azurerm_search_service" "search" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resourceGroupName
  sku                 = var.sku["name"]
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }

  public_network_access_enabled = true
  replica_count                 = 1
  partition_count               = 1
  # semantic_search_sku           = var.semanticSearch 
}

locals {
  // we're using timeadd and we can't pass the day directly need to be hours
  // ToDo: add variable Days_to_expire in script
  // days_to_hours = var.days_to_expire * 24
  days_to_hours = 31 * 24
  // expiration date need to be in a specific format as well
  expiration_date = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "${local.days_to_hours}h")
  
  // add "expiration_date = local.expiration_date" to ressource
}

resource "azurerm_key_vault_secret" "search_service_key" {
  name         = "AZURE-SEARCH-SERVICE-KEY"
  value        = data.azurerm_search_service.search.primary_key
  key_vault_id = var.keyVaultId
  expiration_date = local.expiration_date
}

output "id" {
  value = azurerm_search_service.search.id
}

output "endpoint" {
  value = "https://${azurerm_search_service.search.name}.${var.azure_search_domain}/"
}

output "name" {
  value = azurerm_search_service.search.name
}

data "azurerm_search_service" "search" {
  name                = azurerm_search_service.search.name
  resource_group_name = var.resourceGroupName
}
