# Copyright IBM Corp. 2026

# Unused IAM user credentials should be removed

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "iam-user-unused-credentials-check-enforcement-level" {
  type = string
  default = "advisory"
}

# Terraform does not expose IAM credential last-used timestamps reliably in plan data,
# so this policy validates the AWS managed Config rule that performs the periodic check.
resource_policy "aws_config_config_rule" "iam_unused_credentials_check" {
  enforcement_level = input.iam-user-unused-credentials-check-enforcement-level
  locals {
    is_iam_unused_creds_rule = core::try(attrs.name, "") == "iam-user-unused-credentials-check"

    source_identifier = core::try(attrs.source[0].source_identifier, "")
    is_correct_source = local.source_identifier == "IAM_USER_UNUSED_CREDENTIALS_CHECK"

    rule_owner = core::try(attrs.source[0].owner, "")
    is_aws_managed = local.rule_owner == "AWS"

    input_parameters_raw = core::try(attrs.input_parameters, "{}")
    input_parameters = core::try(core::jsondecode(local.input_parameters_raw), {})
    max_credential_usage_age = core::try(local.input_parameters.maxCredentialUsageAge, "")
    has_fixed_usage_age = local.max_credential_usage_age == "" || local.max_credential_usage_age == 90 || local.max_credential_usage_age == "90"
  }

  filter = local.is_iam_unused_creds_rule

  enforce {
    condition = local.is_correct_source
    error_message = "AWS Config rule '${attrs.name}' must use source identifier 'IAM_USER_UNUSED_CREDENTIALS_CHECK' (current: '${local.source_identifier}'). This rule is required for IAM.8 compliance to monitor unused credentials"
  }

  enforce {
    condition = local.is_aws_managed
    error_message = "AWS Config rule '${attrs.name}' must be AWS-managed (owner: AWS, current: '${local.rule_owner}'). This ensures the rule uses AWS's official implementation for monitoring unused IAM credentials"
  }

  enforce {
    condition = local.has_fixed_usage_age
    error_message = "AWS Config rule '${attrs.name}' must use maxCredentialUsageAge = 90 when input_parameters are provided. Current value: '${local.max_credential_usage_age}'"
  }
}