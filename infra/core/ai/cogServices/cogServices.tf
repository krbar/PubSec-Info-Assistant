resource "azurerm_cognitive_account" "cognitiveService" {
  name                     = var.name
  location                 = var.location
  resource_group_name      = var.resourceGroupName
  kind                     = "CognitiveServices"
  sku_name                 = var.sku["name"]
  tags                     = var.tags
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
  name         = "ENRICHMENT-KEY"
  value        = azurerm_cognitive_account.cognitiveService.primary_access_key
  key_vault_id = var.keyVaultId
  expiration_date = local.expiration_date
}


output "cognitiveServicerAccountName" {
  value = azurerm_cognitive_account.cognitiveService.name
}

output "cognitiveServiceID" {
  value = azurerm_cognitive_account.cognitiveService.id
}

output "cognitiveServiceEndpoint" {
  value = azurerm_cognitive_account.cognitiveService.endpoint
}

