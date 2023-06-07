#data "volterra_namespace" "namespace" {
#  name = var.volterra_namespace_name
#}

resource "volterra_app_firewall" "tier-3" {
  name = "tier-3"
  namespace = var.volterra_namespace_name

  detection_settings {
    signature_selection_setting {
      only_high_accuracy_signatures = true
    }
  }
}

resource "volterra_http_loadbalancer" "tier-3" {
  count = ceil(length(var.tier3_domains) / 32)
  name = format("tier3-%d", count.index)
  namespace = var.volterra_namespace_name
  domains = slice(var.tier3_domains, count.index * 32, min((count.index + 1) * 32, length(var.tier3_domains)))

  https_auto_cert {
    http_redirect = true
    port = 443
  }

  default_route_pools {
    pool {
      namespace = var.volterra_namespace_name
      name = var.volterra_origin_pool
    }
  }

  enable_ip_reputation {
    ip_threat_categories = [
      "SPAM_SOURCES",
      "WINDOWS_EXPLOITS",
      "WEB_ATTACKS",
      "BOTNETS",
      "SCANNERS",
      "REPUTATION",
      "PHISHING",
      "PROXY",
      "MOBILE_THREATS",
      "TOR_PROXY",
      "DENIAL_OF_SERVICE",
      "NETWORK"
    ]
  }

  enable_ddos_detection {
    enable_auto_mitigation = true
  }

  app_firewall {
    name = volterra_app_firewall.tier-3.name
  }
}

resource "volterra_http_loadbalancer" "tier-2" {
  count = ceil(length(var.tier2_domains) / 32)
  name = format("tier2-%d", count.index)
  namespace = var.volterra_namespace_name
  domains = slice(var.tier2_domains, count.index * 32, min((count.index + 1) * 32, length(var.tier2_domains)))

  https_auto_cert {
    http_redirect = true
    port = 443
  }

  default_route_pools {
    pool {
      namespace = var.volterra_namespace_name
      name = var.volterra_origin_pool
    }
  }

  enable_ip_reputation {
    ip_threat_categories = [
      "SPAM_SOURCES",
      "WINDOWS_EXPLOITS",
      "WEB_ATTACKS",
      "BOTNETS",
      "SCANNERS",
      "REPUTATION",
      "PHISHING",
      "PROXY",
      "MOBILE_THREATS",
      "TOR_PROXY",
      "DENIAL_OF_SERVICE",
      "NETWORK"
    ]
  }

  enable_ddos_detection {
    enable_auto_mitigation = true
  }

  app_firewall {
    name = volterra_app_firewall.tier-3.name
  }

  bot_defense {
    regional_endpoint = "US"
    policy {
      protected_app_endpoints {
        metadata {
          name = "endpoints"
        }
        http_methods = [
          "METHOD_ANY"
        ]
        path {
          prefix = "/"
        }
        mitigation {
          flag {
            no_headers = true
          }
        }
      }
      js_insert_all_pages {
        javascript_location = "AFTER_HEAD"
      }
      js_download_path = "/common.js"
      javascript_mode = "ASYNC_JS_NO_CACHING"
    }
  }

  enable_malicious_user_detection = true
  enable_challenge {
    default_mitigation_settings = true
    default_js_challenge_parameters = true
    default_captcha_challenge_parameters = true
  }

  client_side_defense {
    policy {
      js_insert_all_pages = true
    }
  }
}

resource "volterra_app_firewall" "tier-1" {
  name = "tier-1"
  namespace = var.volterra_namespace_name
}

resource "volterra_http_loadbalancer" "tier-1" {
  count = ceil(length(var.tier1_domains) / 32)
  name = format("tier1-%d", count.index)
  namespace = var.volterra_namespace_name
  domains = slice(var.tier1_domains, count.index * 32, min((count.index + 1) * 32, length(var.tier1_domains)))

  https_auto_cert {
    http_redirect = true
    port = 443
  }

  default_route_pools {
    pool {
      namespace = var.volterra_namespace_name
      name = var.volterra_origin_pool
    }
  }

  enable_ip_reputation {
    ip_threat_categories = [
      "SPAM_SOURCES",
      "WINDOWS_EXPLOITS",
      "WEB_ATTACKS",
      "BOTNETS",
      "SCANNERS",
      "REPUTATION",
      "PHISHING",
      "PROXY",
      "MOBILE_THREATS",
      "TOR_PROXY",
      "DENIAL_OF_SERVICE",
      "NETWORK"
    ]
  }

  enable_ddos_detection {
    enable_auto_mitigation = true
  }

  app_firewall {
    name = volterra_app_firewall.tier-3.name
  }

  bot_defense {
    regional_endpoint = "US"
    policy {
      protected_app_endpoints {
        metadata {
          name = "endpoints"
        }
        http_methods = [
          "METHOD_ANY"
        ]
        path {
          prefix = "/"
        }
        mitigation {
          flag {
            no_headers = true
          }
        }
      }
      js_insert_all_pages {
        javascript_location = "AFTER_HEAD"
      }
      js_download_path = "/common.js"
      javascript_mode = "ASYNC_JS_NO_CACHING"
    }
  }

  enable_malicious_user_detection = true
  enable_challenge {
    default_mitigation_settings = true
    default_js_challenge_parameters = true
    default_captcha_challenge_parameters = true
  }

  client_side_defense {
    policy {
      js_insert_all_pages = true
    }
  }

  enable_api_discovery {
  }
}
