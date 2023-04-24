output "appgw" {
  value       = azurerm_application_gateway.appgw
  description = "The properties of the appgw host"
  sensitive   = true
}
