data "azurerm_public_ip_prefix" "ip_prefix" {
  provider            = azurerm.public_ip_prefix
  name                = var.public_ip_prefix_name
  resource_group_name = var.public_ip_prefix_resource_group_name
}

data "azurerm_subnet" "appgw_subnet" {
  for_each             = { for k in var.subnets : k.name => k }
  name                 = each.key
  virtual_network_name = each.value["virtual_network_name"]
  resource_group_name  = each.value["resource_group_name"]
}

data "azurerm_log_analytics_workspace" "logs" {
  provider            = azurerm.logs
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_resource_group_name
}
