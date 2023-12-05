terraform {
  required_providers {
    azurerm = {
      configuration_aliases = [azurerm.logs, azurerm.public_ip_prefix]
      source                = "hashicorp/azurerm"
      version               = "~> 3.20"
    }
  }
  required_version = "~> 1.6.0"
}
