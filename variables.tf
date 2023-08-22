variable "resource_group_name" {
  type        = string
  description = "Resource Group name to deploy to"
}

variable "location" {
  type        = string
  description = "Location of the App Gateway"
}

variable "public_ip_addresses" {
  type = list(object(
    {
      name                    = string
      domain_name_label       = optional(string)
      idle_timeout_in_minutes = optional(string)
    }
  ))
  description = "Public IP addresses"
}

variable "public_ip_prefix_name" {
  type        = string
  description = "Name of the prefix of the public IP of the App Gateway"
}

variable "public_ip_prefix_resource_group_name" {
  type        = string
  description = "Resource group name of the prefix of the public IP of the App Gateway"
}

variable "app_gateway_name" {
  type        = string
  description = "Name of the App Gateway"
}

variable "fips_enabled" {
  type        = bool
  default     = true
  description = "Enable FIPS"
}

variable "zones" {
  type        = list(string)
  default     = null
  description = "Availability zones to deploy to"
}

variable "enable_http2" {
  type        = bool
  default     = true
  description = "Enable HTTP2"
}

variable "force_firewall_policy_association" {
  type        = bool
  default     = true
  description = "Force WAF association"
}

variable "firewall_policy_id" {
  type        = string
  default     = null
  description = "WAF policy ID"
}

variable "sku_name" {
  type        = string
  default     = "WAF_v2"
  description = "Sku of App Gateway, Possible values are Standard_Small, Standard_Medium, Standard_Large, Standard_v2, WAF_Medium, WAF_Large, and WAF_v2."
}

variable "sku_tier" {
  type        = string
  default     = "WAF_v2"
  description = "Possible values are Standard, Standard_v2, WAF and WAF_v2"
}

variable "sku_capacity" {
  type        = number
  default     = 2
  description = "he Capacity of the SKU to use for this Application Gateway. When using a V1 SKU this value must be between 1 and 32, and 1 to 125 for a V2 SKU. This property is optional if autoscale_configuration is set."
}


variable "subnets" {
  type = list(object(
    {
      name                 = string
      virtual_network_name = string
      resource_group_name  = string
    }
  ))
  description = "App Gateway subnets"
}


variable "gateway_ip_configurations" {
  type = list(object(
    {
      name             = string
      subnet_reference = string
    }
  ))
  description = "App Gateway subnet placements"
}

variable "front_end_ports" {
  type = list(object(
    {
      name = string
      port = number
    }
  ))
  description = "Front end ports"
}

variable "frontend_ip_configurations" {
  type = list(object(
    {
      name                          = string
      public_ip_address_reference   = optional(string)
      subnet_reference              = optional(string)
      private_ip_address            = optional(string)
      private_ip_address_allocation = optional(string)
    }
  ))
  description = "Frontend IPs"
}

variable "backend_address_pools" {
  type = list(object(
    {
      name         = string
      fqdns        = optional(list(string))
      ip_addresses = optional(list(string))
    }
  ))
  description = "Backend address pools"
}

variable "backend_http_settings" {
  type = list(object(
    {
      name                                = string
      cookie_based_affinity               = optional(string, "Disabled")
      affinity_cookie_name                = optional(string)
      probe_name                          = string
      host_name                           = optional(string)
      pick_host_name_from_backend_address = optional(bool, true)
      path                                = optional(string, "/")
      port                                = number
      protocol                            = optional(string, "Https")
      request_timeout                     = optional(number, 30)
      trusted_root_certificate_names      = optional(list(string))
      connection_draining_enabled         = optional(bool, true)
      drain_timeout_sec                   = optional(number, 30)
      authentication_certificates         = optional(list(string), [])
    }
  ))
  description = "Backend http settings"
}

variable "http_listeners" {
  type = list(object(
    {
      name                           = string
      frontend_ip_configuration_name = string
      frontend_port_name             = string
      protocol                       = optional(string, "Https")
      host_names                     = list(string)
      require_sni                    = optional(bool, false)
      firewall_policy_id             = optional(string)
      ssl_profile_name               = optional(string)
      custom_error_configurations = optional(list(object(
        {
          status_code           = number
          custom_error_page_url = string
        }
      )), [])
    }
  ))
  description = "HTTP listeners"
}

variable "request_routing_rules" {
  type = list(object(
    {
      name                        = string
      rule_type                   = optional(string, "Basic")
      http_listener_name          = string
      backend_address_pool_name   = optional(string)
      backend_http_settings_name  = optional(string)
      redirect_configuration_name = optional(string)
      rewrite_rule_set_name       = optional(string)
      url_path_map_name           = optional(string)
      priority                    = number
    }
  ))
  description = "HTTP listeners"
}

variable "global" {
  type = object(
    {
      request_buffering_enabled  = optional(bool, true)
      response_buffering_enabled = optional(bool, true)
    }
  )
  default = {
    request_buffering_enabled  = true
    response_buffering_enabled = true
  }
  description = "Buffering settings"
}

variable "trusted_client_certificates" {
  type = list(object(
    {
      name = string
      data = string
    }
  ))
  default     = []
  description = "Client certs"
}

variable "ssl_profiles" {
  type = list(object(
    {
      name                             = string
      trusted_client_certificate_names = optional(list(string))
      verify_client_cert_issuer_dn     = optional(bool, false)
      disabled_protocols               = optional(list(string))
      policy_type                      = optional(string)
      policy_name                      = optional(string)
      cipher_suites                    = optional(list(string))
      min_protocol_version             = optional(string)
    }
  ))
  default     = []
  description = "SSL configurations"
}

variable "authentication_certificates" {
  type = list(object(
    {
      name = string
      data = string
    }
  ))
  default     = []
  description = "Authentication certificates"
}

variable "trusted_root_certificates" {
  type = list(object(
    {
      name                = string
      key_vault_secret_id = string
    }
  ))
  default     = []
  description = "Root certificates"
}

variable "probes" {
  type = list(object(
    {
      name                                      = string
      host                                      = optional(string)
      interval                                  = optional(number, 10)
      protocol                                  = optional(string, "Https")
      path                                      = optional(string, "/")
      timeout                                   = optional(number, 10)
      unhealthy_threshold                       = optional(number, 2)
      port                                      = optional(number, 443)
      pick_host_name_from_backend_http_settings = optional(bool, true)
      minimum_servers                           = optional(number, 0)
    }
  ))
  description = "Health probes"
}

variable "ssl_certificates" {
  type = list(object(
    {
      name                = string
      password            = optional(string)
      key_vault_secret_id = string
    }
  ))
  default     = []
  description = "Front end certificates"
}

variable "url_path_maps" {
  type = list(object(
    {
      name                                = string
      default_backend_address_pool_name   = optional(string)
      default_backend_http_settings_name  = optional(string)
      default_redirect_configuration_name = optional(string)
      default_rewrite_rule_set_name       = optional(string)
      path_rules = list(object(
        {
          name                        = string
          paths                       = list(string)
          backend_address_pool_name   = optional(string)
          backend_http_settings_name  = optional(string)
          redirect_configuration_name = optional(string)
          rewrite_rule_set_name       = optional(string)
          firewall_policy_id          = optional(string)
        }
      ))
    }
  ))
  default     = []
  description = "URL path maps"
}

variable "custom_error_configurations" {
  type = list(object(
    {
      status_code           = string
      custom_error_page_url = string
    }
  ))
  default     = []
  description = "Custom error pages"
}

variable "redirect_configurations" {
  type = list(object(
    {
      name                 = string
      redirect_type        = string
      target_listener_name = optional(string)
      target_url           = optional(string)
      include_path         = optional(bool, false)
      include_query_string = optional(bool, false)
    }
  ))
  default     = []
  description = "URL redirects"
}

variable "autoscale_configuration" {
  type = object(
    {
      min_capacity = optional(number, 2)
      max_capacity = optional(number, 10)
    }
  )
  description = "Autoscale settings"
}

variable "rewrite_rule_sets" {
  type = list(object(
    {
      name = string
      rewrite_rules = list(object(
        {
          name          = string
          rule_sequence = number
          request_header_configurations = optional(list(object(
            {
              header_name  = string
              header_value = string
            }
          )))
          response_header_configurations = optional(list(object(
            {
              header_name  = string
              header_value = string
            }
          )))
          conditions = optional(list(object(
            {
              variable    = string
              pattern     = string
              ignore_case = optional(bool, false)
              negate      = optional(bool, false)
            }
          )))
          url = optional(object(
            {
              path         = optional(string)
              query_string = optional(string)
              components   = optional(string)
              reroute      = optional(bool)
            }
          ))
        }
      ))
    }
  ))
  default     = []
  description = "URL rewrite rule sets"
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Name of Log Analytics Workspace to send diagnostics"
}

variable "log_analytics_workspace_resource_group_name" {
  type        = string
  description = "Resource Group of Log Analytics Workspace to send diagnostics"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
}
