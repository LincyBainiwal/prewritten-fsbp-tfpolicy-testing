# Copyright IBM Corp. 2026

# OpenSearch domains should have audit logging enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0, < 7.0.0"
    }
  }
}

input "opensearch-audit-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_opensearch_domain" "audit_logging_enabled" {
    enforcement_level = input.opensearch-audit-logging-enabled-enforcement-level

    locals {
        # Extract all log publishing options
        log_options = core::try(attrs.log_publishing_options, [])
        has_log_options = core::try(core::length(local.log_options), 0) > 0

        # Find audit log configurations
        audit_logs = local.has_log_options ? [
            for log in local.log_options :
            log if core::try(log.log_type, "") == "AUDIT_LOGS"
        ] : []

        # Check if audit logging exists and is enabled
        has_audit_logs = core::try(core::length(local.audit_logs), 0) > 0
        audit_enabled = local.has_audit_logs ? core::try(local.audit_logs[0].enabled, false) : false
    }

    enforce {
        condition = local.has_log_options && local.has_audit_logs && local.audit_enabled
        error_message = "OpenSearch domain does not have audit logging enabled. Add log_publishing_options block with log_type = \"AUDIT_LOGS\" and enabled = true. Note: Audit logging requires advanced_security_options.enabled = true"
    }
}
