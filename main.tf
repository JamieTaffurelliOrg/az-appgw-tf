resource "azurerm_public_ip" "appgw_public_ip" {
  for_each                = { for k in var.public_ip_addresses : k.name => k }
  name                    = each.key
  resource_group_name     = var.resource_group_name
  location                = var.location
  allocation_method       = "Static"
  zones                   = [1, 2, 3]
  ddos_protection_mode    = "VirtualNetworkInherited"
  domain_name_label       = each.value["domain_name_label"]
  idle_timeout_in_minutes = each.value["idle_timeout_in_minutes"]
  ip_version              = "IPv4"
  public_ip_prefix_id     = data.azurerm_public_ip_prefix.ip_prefix.id
  sku                     = "Standard"
  sku_tier                = "Regional"
  tags                    = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "public_ip_diagnostics" {
  for_each                   = { for k in var.public_ip_addresses : k.name => k }
  name                       = "${var.log_analytics_workspace_name}-security-logging"
  target_resource_id         = azurerm_public_ip.appgw_public_ip[(each.key)].id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs.id

  log {
    category = "DDoSProtectionNotifications"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "DDoSMitigationFlowLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "DDoSMitigationReports"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }
}

resource "azurerm_application_gateway" "appgw" {
  #checkov:skip=CKV_AZURE_120:WAF may be enabled elsewhere
  #checkov:skip=CKV_AZURE_217:Redirects to Https can be used
  #checkov:skip=CKV_AZURE_218:Optionality on SSL policy is required
  name                              = var.app_gateway_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  fips_enabled                      = var.fips_enabled
  zones                             = var.zones
  enable_http2                      = var.enable_http2
  force_firewall_policy_association = var.force_firewall_policy_association
  firewall_policy_id                = var.firewall_policy_id

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.sku_capacity
  }

  dynamic "gateway_ip_configuration" {
    for_each = { for k in var.gateway_ip_configurations : k.name => k }

    content {
      name      = gateway_ip_configuration.key
      subnet_id = data.azurerm_subnet.appgw_subnet[(gateway_ip_configuration.value["subnet_reference"])].id
    }
  }

  dynamic "frontend_port" {
    for_each = { for k in var.front_end_ports : k.name => k }
    content {
      name = frontend_port.key
      port = frontend_port.value["port"]
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = { for k in var.frontend_ip_configurations : k.name => k }

    content {
      name                          = frontend_ip_configuration.key
      public_ip_address_id          = frontend_ip_configuration.value["public_ip_address_reference"] == null ? null : azurerm_public_ip.appgw_public_ip[(frontend_ip_configuration.value["public_ip_address_reference"])].id
      subnet_id                     = frontend_ip_configuration.value["subnet_reference"] == null ? null : data.azurerm_subnet.appgw_subnet[(frontend_ip_configuration.value["subnet_reference"])].id
      private_ip_address            = frontend_ip_configuration.value["private_ip_address"]
      private_ip_address_allocation = frontend_ip_configuration.value["private_ip_address_allocation"]
    }
  }

  dynamic "backend_address_pool" {
    for_each = { for k in var.backend_address_pools : k.name => k }

    content {
      name         = backend_address_pool.key
      fqdns        = backend_address_pool.value["fqdns"]
      ip_addresses = backend_address_pool.value["ip_addresses"]
    }
  }

  dynamic "backend_http_settings" {
    for_each = { for k in var.backend_http_settings : k.name => k }

    content {
      name                                = backend_http_settings.key
      cookie_based_affinity               = backend_http_settings.value["cookie_based_affinity"]
      affinity_cookie_name                = backend_http_settings.value["affinity_cookie_name"]
      probe_name                          = backend_http_settings.value["probe_name"]
      host_name                           = backend_http_settings.value["host_name"]
      pick_host_name_from_backend_address = backend_http_settings.value["pick_host_name_from_backend_address"]
      path                                = backend_http_settings.value["path"]
      port                                = backend_http_settings.value["port"]
      protocol                            = backend_http_settings.value["protocol"]
      request_timeout                     = backend_http_settings.value["request_timeout"]
      trusted_root_certificate_names      = backend_http_settings.value["trusted_root_certificate_names"]

      connection_draining {
        enabled           = backend_http_settings.value["connection_draining_enabled"]
        drain_timeout_sec = backend_http_settings.value["drain_timeout_sec"]
      }

      dynamic "authentication_certificate" {
        for_each = { for k in backend_http_settings.value["authentication_certificates"] : k => k if k != null }

        content {
          name = authentication_certificate.key
        }
      }
    }
  }

  dynamic "http_listener" {
    for_each = { for k in var.http_listeners : k.name => k }

    content {
      name                           = http_listener.key
      frontend_ip_configuration_name = http_listener.value["frontend_ip_configuration_name"]
      frontend_port_name             = http_listener.value["frontend_port_name"]
      protocol                       = http_listener.value["protocol"]
      host_names                     = http_listener.value["host_names"]
      require_sni                    = http_listener.value["require_sni"]
      firewall_policy_id             = http_listener.value["firewall_policy_id"]
      ssl_profile_name               = http_listener.value["ssl_profile_name"]

      dynamic "custom_error_configuration" {
        for_each = { for k in http_listener.value["custom_error_configurations"] : k.status_code => k if k != null }

        content {
          status_code           = custom_error_configuration.key
          custom_error_page_url = custom_error_configuration.value["custom_error_page_url"]
        }
      }
    }
  }

  dynamic "request_routing_rule" {
    for_each = { for k in var.request_routing_rules : k.name => k }

    content {
      name                        = request_routing_rule.key
      rule_type                   = request_routing_rule.value["rule_type"]
      http_listener_name          = request_routing_rule.value["http_listener_name"]
      backend_address_pool_name   = request_routing_rule.value["backend_address_pool_name"]
      backend_http_settings_name  = request_routing_rule.value["backend_http_settings_name"]
      redirect_configuration_name = request_routing_rule.value["redirect_configuration_name"]
      rewrite_rule_set_name       = request_routing_rule.value["rewrite_rule_set_name"]
      url_path_map_name           = request_routing_rule.value["url_path_map_name"]
      priority                    = request_routing_rule.value["priority"]
    }
  }

  global {
    request_buffering_enabled  = var.global.request_buffering_enabled
    response_buffering_enabled = var.global.response_buffering_enabled
  }

  dynamic "trusted_client_certificate" {
    for_each = { for k in var.trusted_client_certificates : k.name => k if k != null }

    content {
      name = trusted_client_certificate.key
      data = trusted_client_certificate.value["data"]
    }
  }

  dynamic "ssl_profile" {
    for_each = { for k in var.ssl_profiles : k.name => k if k != null }

    content {
      name                             = ssl_profile.key
      trusted_client_certificate_names = ssl_profile.value["trusted_client_certificate_names"]
      verify_client_cert_issuer_dn     = ssl_profile.value["trusted_client_certificate_names"]

      ssl_policy {
        disabled_protocols   = ssl_profile.value["disabled_protocols"]
        policy_type          = ssl_profile.value["policy_type"]
        policy_name          = ssl_profile.value["policy_name"]
        cipher_suites        = ssl_profile.value["cipher_suites"]
        min_protocol_version = ssl_profile.value["min_protocol_version"]
      }
    }
  }

  dynamic "authentication_certificate" {
    for_each = { for k in var.authentication_certificates : k.name => k if k != null }

    content {
      name = authentication_certificate.key
      data = authentication_certificate.value["data"]
    }
  }

  dynamic "trusted_root_certificate" {
    for_each = { for k in var.trusted_root_certificates : k.name => k if k != null }

    content {
      name                = trusted_root_certificate.key
      key_vault_secret_id = trusted_root_certificate.value["key_vault_secret_id"]
    }
  }

  dynamic "probe" {
    for_each = { for k in var.probes : k.name => k }

    content {
      name                                      = probe.key
      host                                      = probe.value["host"]
      interval                                  = probe.value["interval"]
      protocol                                  = probe.value["protocol"]
      path                                      = probe.value["path"]
      timeout                                   = probe.value["timeout"]
      unhealthy_threshold                       = probe.value["unhealthy_threshold"]
      port                                      = probe.value["port"]
      pick_host_name_from_backend_http_settings = probe.value["pick_host_name_from_backend_http_settings"]
      minimum_servers                           = probe.value["minimum_servers"]
    }
  }

  dynamic "ssl_certificate" {
    for_each = { for k in var.ssl_certificates : k.name => k }

    content {
      name                = ssl_certificate.key
      password            = ssl_certificate.value["password"]
      key_vault_secret_id = ssl_certificate.value["key_vault_secret_id"]
    }
  }

  dynamic "url_path_map" {
    for_each = { for k in var.url_path_maps : k.name => k if k != null }

    content {
      name                                = url_path_map.key
      default_backend_address_pool_name   = url_path_map.value["default_backend_address_pool_name"]
      default_backend_http_settings_name  = url_path_map.value["default_backend_http_settings_name"]
      default_redirect_configuration_name = url_path_map.value["default_redirect_configuration_name"]
      default_rewrite_rule_set_name       = url_path_map.value["default_rewrite_rule_set_name"]

      dynamic "path_rule" {
        for_each = { for k in url_path_map.value["path_rules"] : k.name => k if k != null }

        content {
          name                        = path_rule.key
          paths                       = path_rule.value["paths"]
          backend_address_pool_name   = path_rule.value["backend_address_pool_name"]
          backend_http_settings_name  = path_rule.value["backend_http_settings_name"]
          redirect_configuration_name = path_rule.value["redirect_configuration_name"]
          rewrite_rule_set_name       = path_rule.value["rewrite_rule_set_name"]
          firewall_policy_id          = path_rule.value["firewall_policy_id"]
        }
      }
    }
  }

  dynamic "custom_error_configuration" {
    for_each = { for k in var.custom_error_configurations : k.status_code => k if k != null }

    content {
      status_code           = custom_error_configuration.key
      custom_error_page_url = custom_error_configuration.value["custom_error_page_url"]
    }
  }

  dynamic "redirect_configuration" {
    for_each = { for k in var.redirect_configurations : k.name => k if k != null }

    content {
      name                 = redirect_configuration.key
      redirect_type        = redirect_configuration.value["redirect_type"]
      target_listener_name = redirect_configuration.value["target_listener_name"]
      target_url           = redirect_configuration.value["target_url"]
      include_path         = redirect_configuration.value["include_path"]
      include_query_string = redirect_configuration.value["include_query_string"]
    }
  }

  dynamic "autoscale_configuration" {
    for_each = var.autoscale_configuration != null ? var.autoscale_configuration : {}

    content {
      min_capacity = autoscale_configuration.value["min_capacity"]
      max_capacity = autoscale_configuration.value["max_capacity"]
    }
  }

  dynamic "rewrite_rule_set" {
    for_each = { for k in var.rewrite_rule_sets : k.name => k if k != null }

    content {
      name = rewrite_rule_set.key

      dynamic "rewrite_rule" {
        for_each = { for k in rewrite_rule_set.value["rewrite_rules"] : k.name => k }

        content {
          name          = rewrite_rule.key
          rule_sequence = rewrite_rule.value["rule_sequence"]

          dynamic "request_header_configuration" {
            for_each = { for k in rewrite_rule.value["request_header_configurations"] : k.header_name => k }

            content {
              header_name  = request_header_configuration.key
              header_value = request_header_configuration.value["header_value"]
            }
          }

          dynamic "response_header_configuration" {
            for_each = { for k in rewrite_rule.value["response_header_configurations"] : k.header_name => k }

            content {
              header_name  = response_header_configuration.key
              header_value = response_header_configuration.value["header_value"]
            }
          }

          dynamic "condition" {
            for_each = { for k in rewrite_rule.value["conditions"] : k => k }

            content {
              variable    = condition.value["variable"]
              pattern     = condition.value["pattern"]
              ignore_case = condition.value["ignore_case"]
              negate      = condition.value["negate"]
            }
          }

          dynamic "url" {
            for_each = rewrite_rule.value["url"] != null ? rewrite_rule.value["url"] : {}

            content {
              path         = url.value["path"]
              query_string = url.value["query_string"]
              components   = url.value["components"]
              reroute      = url.value["reroute"]
            }
          }
        }
      }
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "appgw_diagnostics" {
  name                       = "${var.log_analytics_workspace_name}-security-logging"
  target_resource_id         = azurerm_application_gateway.appgw.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs.id

  log {
    category = "ApplicationGatewayAccessLog"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "ApplicationGatewayPerformanceLog"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "ApplicationGatewayFirewallLog"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }
}
