data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = var.name
  location                    = var.location
  resource_group_name         = var.resourceGroupName // Replace with your resource group name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  tags                        = var.tags
  enabled_for_template_deployment = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  enable_rbac_authorization   = true
}

 
resource "azurerm_key_vault_access_policy" "infoasst" {
  depends_on  = [
    azurerm_key_vault.kv
  ]
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.kvAccessObjectId
 
  key_permissions = [
      "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import",
      "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update",
      "Verify", "WrapKey"
    ]
 
  secret_permissions = [
      "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
    ]
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

resource "azurerm_key_vault_secret" "spClientKeySecret" {
  depends_on  = [
    azurerm_key_vault_access_policy.infoasst,
    azurerm_key_vault.kv
  ]
  name         = "AZURE-CLIENT-SECRET"
  value        = var.spClientSecret
  key_vault_id = azurerm_key_vault.kv.id
  expiration_date = local.expiration_date
}

output "keyVaultName" {
  value = azurerm_key_vault.kv.name
}

output "keyVaultId" {
  value = azurerm_key_vault.kv.id
}

output "keyVaultUri" {
  value = azurerm_key_vault.kv.vault_uri
}