resource "azurerm_cognitive_account" "account" {
  count                           = var.useExistingAOAIService ? 0 : 1
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resourceGroupName
  kind                            = var.kind
  sku_name                        = var.sku["name"]
  public_network_access_enabled   = var.publicNetworkAccess == "Enabled" ? true : false
  tags = var.tags
}

resource "azurerm_cognitive_deployment" "deployment" {
  count                 = var.useExistingAOAIService ? 0 : length(var.deployments)
  name                  = var.deployments[count.index].name
  cognitive_account_id  = azurerm_cognitive_account.account[0].id
  rai_policy_name       = var.deployments[count.index].rai_policy_name
  model {
    format              = "OpenAI"
    name                = var.deployments[count.index].model.name
    version             = var.deployments[count.index].model.version
  }
  scale {
    type                = "Standard"
    capacity            = var.deployments[count.index].sku_capacity
  }
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

resource "azurerm_key_vault_secret" "openaiServiceKeySecret" {
  name         = "AZURE-OPENAI-SERVICE-KEY"
  value        = var.useExistingAOAIService ? var.openaiServiceKey : azurerm_cognitive_account.account[0].primary_access_key
  key_vault_id = var.keyVaultId
  expiration_date = local.expiration_date
}

output "name" {
  value = var.useExistingAOAIService ? "" : azurerm_cognitive_account.account[0].name
}

output "endpoint" {
  value = var.useExistingAOAIService ? "" : azurerm_cognitive_account.account[0].endpoint
}

output "id" {
  value = var.useExistingAOAIService ? "" : azurerm_cognitive_account.account[0].id
}