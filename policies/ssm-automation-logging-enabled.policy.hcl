# Copyright IBM Corp. 2026

# SSM Automation should have CloudWatch logging enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.24.0, < 7.0.0"
    }
  }
}

input "ssm-automation-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

# Validate SSM service settings have non-empty values
resource_policy "aws_ssm_service_setting" "automation_logging_settings" {
  enforcement_level = input.ssm-automation-logging-enabled-enforcement-level
  locals {
    setting_id = core::try(attrs.setting_id, "")
    setting_value = core::try(attrs.setting_value, "")
    has_value = local.setting_value != "" && local.setting_value != null
  }

  enforce {
    condition = local.has_value
    error_message = "SSM service setting '${local.setting_id}' must have a non-empty value configured. For SSM Automation logging, ensure customer-script-log-destination is 'CloudWatch' and customer-script-log-group-name is set"
  }
}

# Validate that CloudWatch log groups have valid names
resource_policy "aws_cloudwatch_log_group" "log_group_name_required" {
  enforcement_level = input.ssm-automation-logging-enabled-enforcement-level
  locals {
    log_group_name = core::try(attrs.name, "")
    has_name = local.log_group_name != "" && local.log_group_name != null
  }

  enforce {
    condition = local.has_name
    error_message = "CloudWatch log group must have a valid name configured"
  }
}
