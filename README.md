# az-appgw-tf
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.4.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.20 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.20 |
| <a name="provider_azurerm.logs"></a> [azurerm.logs](#provider\_azurerm.logs) | ~> 3.20 |
| <a name="provider_azurerm.public_ip_prefix"></a> [azurerm.public\_ip\_prefix](#provider\_azurerm.public\_ip\_prefix) | ~> 3.20 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_gateway.appgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_monitor_diagnostic_setting.appgw_diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.public_ip_diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_public_ip.appgw_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_log_analytics_workspace.logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |
| [azurerm_public_ip_prefix.ip_prefix](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip_prefix) | data source |
| [azurerm_subnet.appgw_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_gateway_name"></a> [app\_gateway\_name](#input\_app\_gateway\_name) | Name of the App Gateway | `string` | n/a | yes |
| <a name="input_authentication_certificates"></a> [authentication\_certificates](#input\_authentication\_certificates) | Authentication certificates | <pre>list(object(<br>    {<br>      name = string<br>      data = string<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_autoscale_configuration"></a> [autoscale\_configuration](#input\_autoscale\_configuration) | Autoscale settings | <pre>object(<br>    {<br>      min_capacity               = optional(number, 2)<br>      response_buffering_enabled = optional(number, 10)<br>    }<br>  )</pre> | <pre>{<br>  "request_buffering_enabled": 2,<br>  "response_buffering_enabled": 10<br>}</pre> | no |
| <a name="input_backend_address_pools"></a> [backend\_address\_pools](#input\_backend\_address\_pools) | Backend address pools | <pre>list(object(<br>    {<br>      name         = string<br>      fqdns        = optional(list(string))<br>      ip_addresses = optional(list(string))<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_backend_http_settings"></a> [backend\_http\_settings](#input\_backend\_http\_settings) | Backend http settings | <pre>list(object(<br>    {<br>      name                                = string<br>      cookie_based_affinity               = optional(string, "Disabled")<br>      affinity_cookie_name                = optional(string)<br>      probe_name                          = string<br>      host_name                           = optional(string)<br>      pick_host_name_from_backend_address = optional(bool, true)<br>      path                                = optional(string, "/")<br>      port                                = number<br>      protocol                            = optional(string, "Https")<br>      request_timeout                     = optional(number, 30)<br>      trusted_root_certificate_names      = optional(string)<br>      connection_draining_enabled         = optional(bool, true)<br>      drain_timeout_sec                   = optional(number, 30)<br>      authentication_certificates         = optional(list(string), [])<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_custom_error_configurations"></a> [custom\_error\_configurations](#input\_custom\_error\_configurations) | Custom error pages | <pre>list(object(<br>    {<br>      status_code           = string<br>      custom_error_page_url = string<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_enable_http2"></a> [enable\_http2](#input\_enable\_http2) | Enable HTTP2 | `bool` | `true` | no |
| <a name="input_fips_enabled"></a> [fips\_enabled](#input\_fips\_enabled) | Enable FIPS | `bool` | `true` | no |
| <a name="input_force_firewall_policy_association"></a> [force\_firewall\_policy\_association](#input\_force\_firewall\_policy\_association) | Force WAF association | `bool` | `true` | no |
| <a name="input_front_end_ports"></a> [front\_end\_ports](#input\_front\_end\_ports) | Front end ports | <pre>list(object(<br>    {<br>      name = string<br>      port = number<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_frontend_ip_configurations"></a> [frontend\_ip\_configurations](#input\_frontend\_ip\_configurations) | Frontend IPs | <pre>list(object(<br>    {<br>      name                          = string<br>      public_ip_address_reference   = optional(string)<br>      subnet_reference              = optional(string)<br>      private_ip_address            = optional(string)<br>      private_ip_address_allocation = optional(string)<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_gateway_ip_configurations"></a> [gateway\_ip\_configurations](#input\_gateway\_ip\_configurations) | App Gateway subnet placements | <pre>list(object(<br>    {<br>      name             = string<br>      subnet_reference = string<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_global"></a> [global](#input\_global) | Buffering settings | <pre>object(<br>    {<br>      request_buffering_enabled  = optional(bool, true)<br>      response_buffering_enabled = optional(bool, true)<br>    }<br>  )</pre> | <pre>{<br>  "request_buffering_enabled": true,<br>  "response_buffering_enabled": true<br>}</pre> | no |
| <a name="input_http_listeners"></a> [http\_listeners](#input\_http\_listeners) | HTTP listeners | <pre>list(object(<br>    {<br>      name                           = string<br>      frontend_ip_configuration_name = string<br>      frontend_port_name             = string<br>      protocol                       = optional(string, "Https")<br>      host_names                     = list(string)<br>      require_sni                    = optional(bool, false)<br>      firewall_policy_id             = optional(string)<br>      ssl_profile_name               = optional(string)<br>      custom_error_configuration = optional(list(object(<br>        {<br>          status_code           = number<br>          custom_error_page_url = string<br>        }<br>      )), [])<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location of the App Gateway | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | Name of Log Analytics Workspace to send diagnostics | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_resource_group_name"></a> [log\_analytics\_workspace\_resource\_group\_name](#input\_log\_analytics\_workspace\_resource\_group\_name) | Resource Group of Log Analytics Workspace to send diagnostics | `string` | n/a | yes |
| <a name="input_probes"></a> [probes](#input\_probes) | Health probes | <pre>list(object(<br>    {<br>      name                                      = string<br>      host                                      = optional(string)<br>      interval                                  = optional(number, 10)<br>      protocol                                  = optional(string, "Https")<br>      path                                      = optional(string, "/")<br>      timeout                                   = optional(number, 10)<br>      unhealthy_threshold                       = optional(number, 2)<br>      port                                      = optional(number, 443)<br>      pick_host_name_from_backend_http_settings = optional(bool, true)<br>      minimum_servers                           = optional(number, 0)<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_public_ip_addresses"></a> [public\_ip\_addresses](#input\_public\_ip\_addresses) | Public IP addresses | <pre>list(object(<br>    {<br>      name                    = string<br>      domain_name_label       = optional(string)<br>      idle_timeout_in_minutes = optional(string)<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_public_ip_prefix_name"></a> [public\_ip\_prefix\_name](#input\_public\_ip\_prefix\_name) | Name of the prefix of the public IP of the App Gateway | `string` | n/a | yes |
| <a name="input_public_ip_prefix_resource_group_name"></a> [public\_ip\_prefix\_resource\_group\_name](#input\_public\_ip\_prefix\_resource\_group\_name) | Resource group name of the prefix of the public IP of the App Gateway | `string` | n/a | yes |
| <a name="input_redirect_configurations"></a> [redirect\_configurations](#input\_redirect\_configurations) | URL redirects | <pre>list(object(<br>    {<br>      name                 = string<br>      redirect_type        = string<br>      target_listener_name = optional(string)<br>      target_url           = optional(string)<br>      include_path         = optional(bool, false)<br>      include_query_string = optional(bool, false)<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_request_routing_rules"></a> [request\_routing\_rules](#input\_request\_routing\_rules) | HTTP listeners | <pre>list(object(<br>    {<br>      name                        = string<br>      rule_type                   = optional(string, "Basic")<br>      http_listener_name          = string<br>      backend_address_pool_name   = optional(string)<br>      backend_http_settings_name  = optional(string)<br>      redirect_configuration_name = optional(string)<br>      rewrite_rule_set_name       = optional(string)<br>      url_path_map_name           = optional(string)<br>      priority                    = number<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group name to deploy to | `string` | n/a | yes |
| <a name="input_rewrite_rule_sets"></a> [rewrite\_rule\_sets](#input\_rewrite\_rule\_sets) | URL rewrite rule sets | <pre>list(object(<br>    {<br>      name = string<br>      rewrite_rules = list(object(<br>        {<br>          name          = string<br>          rule_sequence = number<br>          request_header_configurations = optional(list(object(<br>            {<br>              header_name  = string<br>              header_value = string<br>            }<br>          )))<br>          response_header_configurations = optional(list(object(<br>            {<br>              header_name  = string<br>              header_value = string<br>            }<br>          )))<br>          conditions = optional(list(object(<br>            {<br>              variable    = string<br>              pattern     = string<br>              ignore_case = optional(bool, false)<br>              negate      = optional(bool, false)<br>            }<br>          )))<br>          url = optional(object(<br>            {<br>              path         = optional(string)<br>              query_string = optional(string)<br>              components   = optional(string)<br>              reroute      = optional(bool)<br>            }<br>          ))<br>        }<br>      ))<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_sku_capacity"></a> [sku\_capacity](#input\_sku\_capacity) | he Capacity of the SKU to use for this Application Gateway. When using a V1 SKU this value must be between 1 and 32, and 1 to 125 for a V2 SKU. This property is optional if autoscale\_configuration is set. | `number` | `2` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | Sku of App Gateway, Possible values are Standard\_Small, Standard\_Medium, Standard\_Large, Standard\_v2, WAF\_Medium, WAF\_Large, and WAF\_v2. | `string` | `"WAF_v2"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | Possible values are Standard, Standard\_v2, WAF and WAF\_v2 | `string` | `"WAF_v2"` | no |
| <a name="input_ssl_certificates"></a> [ssl\_certificates](#input\_ssl\_certificates) | Front end certificates | <pre>list(object(<br>    {<br>      name                = string<br>      password            = optional(string)<br>      key_vault_secret_id = string<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_ssl_profiles"></a> [ssl\_profiles](#input\_ssl\_profiles) | SSL configurations | <pre>list(object(<br>    {<br>      name                             = string<br>      trusted_client_certificate_names = optional(list(string))<br>      verify_client_cert_issuer_dn     = optional(bool, false)<br>      disabled_protocols               = optional(list(string))<br>      policy_type                      = optional(string)<br>      policy_name                      = optional(string)<br>      cipher_suites                    = optional(list(string))<br>      min_protocol_version             = optional(string)<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | App Gateway subnets | <pre>list(object(<br>    {<br>      name                 = string<br>      virtual_network_name = string<br>      resource_group_name  = string<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply | `map(string)` | n/a | yes |
| <a name="input_trusted_client_certificates"></a> [trusted\_client\_certificates](#input\_trusted\_client\_certificates) | Client certs | <pre>list(object(<br>    {<br>      name = string<br>      data = string<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_trusted_root_certificates"></a> [trusted\_root\_certificates](#input\_trusted\_root\_certificates) | Root certificates | <pre>list(object(<br>    {<br>      name                = string<br>      key_vault_secret_id = string<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_url_path_maps"></a> [url\_path\_maps](#input\_url\_path\_maps) | URL path maps | <pre>list(object(<br>    {<br>      name                                = string<br>      default_backend_address_pool_name   = optional(string)<br>      default_backend_http_settings_name  = optional(string)<br>      default_redirect_configuration_name = optional(string)<br>      default_rewrite_rule_set_name       = optional(string)<br>      path_rules = list(object(<br>        {<br>          name                        = string<br>          paths                       = list(string)<br>          backend_address_pool_name   = optional(string)<br>          backend_http_settings_name  = optional(string)<br>          redirect_configuration_name = optional(string)<br>          rewrite_rule_set_name       = optional(string)<br>          firewall_policy_id          = optional(string)<br>        }<br>      ))<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | Availability zones to deploy to | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_appgw"></a> [appgw](#output\_appgw) | The properties of the appgw host |
<!-- END_TF_DOCS -->