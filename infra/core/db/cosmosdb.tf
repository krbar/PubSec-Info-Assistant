

locals {
  consistencyPolicy = {
    Eventual = {
      defaultConsistencyLevel = "Eventual"
    }
    ConsistentPrefix = {
      defaultConsistencyLevel = "ConsistentPrefix"
    }
    Session = {
      defaultConsistencyLevel = "Session"
    }
    BoundedStaleness = {
      defaultConsistencyLevel = "BoundedStaleness"
      maxStalenessPrefix      = var.maxStalenessPrefix
      maxIntervalInSeconds    = var.maxIntervalInSeconds
    }
    Strong = {
      defaultConsistencyLevel = "Strong"
    }
  }
  locations = [
    {
      locationName     = var.location
      failoverPriority = 0
      isZoneRedundant  = false
    }
  ]
}



resource "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                = lower(var.name)
  location            = var.location
  resource_group_name = var.resourceGroupName
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = var.defaultConsistencyLevel
    max_interval_in_seconds = var.maxIntervalInSeconds
    max_staleness_prefix    = var.maxStalenessPrefix
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  tags = var.tags
}

resource "azurerm_cosmosdb_sql_database" "log_database" {
  name                = var.logDatabaseName
  resource_group_name = var.resourceGroupName
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
}

resource "azurerm_cosmosdb_sql_container" "log_container" {
  name                = var.logContainerName
  resource_group_name = var.resourceGroupName
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
  database_name       = azurerm_cosmosdb_sql_database.log_database.name

  partition_key_path = "/file_name"

  autoscale_settings {
    max_throughput = var.autoscaleMaxThroughput
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

resource "azurerm_key_vault_secret" "cosmos_db_key" {
  name                = "COSMOSDB-KEY"
  value               = azurerm_cosmosdb_account.cosmosdb_account.primary_key
  key_vault_id        = var.keyVaultId
  expiration_date     = local.expiration_date
}

output "CosmosDBEndpointURL" {
  value = azurerm_cosmosdb_account.cosmosdb_account.endpoint
}

output "CosmosDBLogDatabaseName" {
  value = azurerm_cosmosdb_sql_database.log_database.name
}

output "CosmosDBLogContainerName" {
  value = azurerm_cosmosdb_sql_container.log_container.name
}