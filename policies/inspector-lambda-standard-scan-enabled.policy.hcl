# Copyright IBM Corp. 2026

# Amazon Inspector Lambda standard scanning should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.59.0, < 7.0.0"
    }
  }
}

input "inspector-lambda-standard-scan-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_inspector2_enabler" "lambda_scanning_enabled" {
    enforcement_level = input.inspector-lambda-standard-scan-enabled-enforcement-level
    filter = attrs.resource_types != null

    locals {
        resource_types = core::try(attrs.resource_types, [])
    }

    enforce {
        condition = core::contains(local.resource_types, "LAMBDA")
        error_message = "Amazon Inspector Lambda scanning must be enabled. Add 'LAMBDA' to the resource_types list to enable Lambda scanning"
    }
}

resource_policy "aws_inspector2_organization_configuration" "lambda_org_scanning_enabled" {
    enforcement_level = input.inspector-lambda-standard-scan-enabled-enforcement-level
    filter = core::try(attrs.auto_enable, null) != null && core::length(core::try(attrs.auto_enable, [])) > 0
    enforce {
        condition = core::try(attrs.auto_enable[0].lambda, false) == true
        error_message = "Amazon Inspector Lambda scanning must be enabled. Set 'auto_enable.lambda = true' to enable Lambda scanning"
    }
}
