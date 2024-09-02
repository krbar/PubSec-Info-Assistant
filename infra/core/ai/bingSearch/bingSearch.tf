locals {
  arm_file_path = "arm_templates/bing_search/bing.template.json"
}

resource "azurerm_resource_group_template_deployment" "bing_search" {
  count               = var.enableWebChat ? 1 : 0
  resource_group_name = var.resourceGroupName
  parameters_content = jsonencode({
    "name"                      = { value = "${var.name}" },
    "location"                  = { value = "Global" },
    "sku"                       = { value = "${var.sku}" },
    "tags"                      = { value = var.tags },
  })
  
  template_content = templatefile(local.arm_file_path, {
    arm_template_schema_mgmt_api = var.arm_template_schema_mgmt_api
  })
  # The filemd5 forces this to run when the file is changed
  # this ensures the keys are up-to-date
  name            = "bingsearch-${filemd5(local.arm_file_path)}"
  deployment_mode = "Incremental"
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

resource "azurerm_key_vault_secret" "bing_search_key" {
  name         = "BINGSEARCH-KEY"
  value        = var.enableWebChat ? jsondecode(azurerm_resource_group_template_deployment.bing_search[0].output_content).key1.value : ""
  key_vault_id = var.keyVaultId
  expiration_date = local.expiration_date
}