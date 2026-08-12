# Copyright IBM Corp. 2026

# Route 53 public hosted zones should log DNS queries

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "route53-query-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

locals {
    all_query_logs = core::getresources("aws_route53_query_log", {})
    
    # Build lookup map for O(1) performance: zone_id -> query_log
    query_log_map = {
        for log in local.all_query_logs :
        log.zone_id => log
    }
}

resource_policy "aws_route53_zone" "dns_query_logging_enabled" {
    enforcement_level = input.route53-query-logging-enabled-enforcement-level
    # Only check public hosted zones (private zones have vpc blocks)
    filter = core::try(core::length(attrs.vpc), 0) == 0
    
    locals {
        # Check if this zone has query logging configured
        has_query_logging = core::try(local.query_log_map[attrs.zone_id], null) != null
        
        zone_name = core::try(attrs.name, attrs.zone_id)
    }
    
    enforce {
        condition = local.has_query_logging
        error_message = "Route 53 public hosted zone '${local.zone_name}' must have DNS query logging enabled. Create an aws_route53_query_log resource with zone_id = ${attrs.zone_id}"
    }
}
