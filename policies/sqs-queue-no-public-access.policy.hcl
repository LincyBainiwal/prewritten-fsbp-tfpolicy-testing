# Copyright IBM Corp. 2026

# SQS queue access policies should not allow public access

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "sqs-queue-no-public-access-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_sqs_queue_policy" "no_public_access" {
    enforcement_level = input.sqs-queue-no-public-access-enforcement-level
    locals {
        policy_value = core::try(attrs.policy, null)
    }
    
    filter = local.policy_value != null

    enforce {
        condition = true
        error_message = "LIMITATION: Cannot validate SQS queue policy for public access. Terraform Policy lacks JSON parsing and string pattern matching functions required to inspect policy documents. Use AWS Config rule 'sqs-queue-no-public-access' instead"
    }
}

resource_policy "aws_sqs_queue" "no_public_access_inline" {
    enforcement_level = input.sqs-queue-no-public-access-enforcement-level
    locals {
        policy_value = core::try(attrs.policy, null)
    }
    
    filter = local.policy_value != null

    enforce {
        condition = true
        error_message = "LIMITATION: Cannot validate SQS queue inline policy for public access. Terraform Policy lacks JSON parsing and string pattern matching functions required to inspect policy documents. Use AWS Config rule 'sqs-queue-no-public-access' instead"
    }
}
