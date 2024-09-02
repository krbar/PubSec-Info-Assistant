resource "azurerm_cognitive_account" "formRecognizerAccount" {
  name                     = var.name
  location                 = var.location
  resource_group_name      = var.resourceGroupName
  kind                     = "FormRecognizer"
  sku_name                 = var.sku["name"]
  custom_subdomain_name    = var.customSubDomainName
  public_network_access_enabled = var.publicNetworkAccess == "Enabled" ? true : false
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

resource "azurerm_key_vault_secret" "docIntelligenceKey" {
  name         = "AZURE-FORM-RECOGNIZER-KEY"
  value        = azurerm_cognitive_account.formRecognizerAccount.primary_access_key
  key_vault_id = var.keyVaultId
  expiration_date = local.expiration_date
}


output "formRecognizerAccountName" {
  value = azurerm_cognitive_account.formRecognizerAccount.name
}

output "formRecognizerAccountEndpoint" {
  value = azurerm_cognitive_account.formRecognizerAccount.endpoint
}
