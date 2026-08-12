# Copyright IBM Corp. 2026

# SSM documents should have the block public sharing setting enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.24.0, < 7.0.0"
    }
  }
}

input "ssm-automation-block-public-sharing-enforcement-level" {
  type = string
  default = "advisory"
}

# Check account-level block public sharing setting
resource_policy "aws_ssm_service_setting" "block_public_sharing" {
    enforcement_level = input.ssm-automation-block-public-sharing-enforcement-level
    locals {
        setting_id = core::try(attrs.setting_id, "")
        setting_value = core::try(attrs.setting_value, "")
        required_setting_id = "/ssm/documents/console/public-sharing-permission"
    }
    
    enforce {
        condition = local.setting_id == local.required_setting_id
        error_message = "This policy must evaluate the SSM block public sharing service setting. Ensure setting_id is '${local.required_setting_id}'"
    }

    enforce {
        condition = local.setting_value == "Disable"
        error_message = "SSM block public sharing must be enabled at the account level. Set the SSM service setting value to 'Disable' to prevent public sharing of SSM documents"
    }
}
