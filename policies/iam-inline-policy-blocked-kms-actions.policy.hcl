# Copyright IBM Corp. 2026

# IAM principals should not have IAM inline policies that allow decryption actions on all KMS keys
#
# NOTE: This policy uses exact string matching for blocked actions. Wildcard patterns (e.g., kms:*) are NOT supported.
# Users must explicitly list all blocked actions in the CSV format.
# Example: "kms:Decrypt,kms:ReEncryptFrom,kms:ReEncryptTo,kms:*"

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "iam-inline-policy-blocked-kms-actions-enforcement-level" {
  type = string
  default = "advisory"
}

input "blocked_action_pattern"{
    type = string
    default = "kms:Decrypt,kms:ReEncryptFrom,kms:*"
}

resource_policy "aws_iam_user_policy" "iam-inline-blocked-kms-actions-user" {
    enforcement_level = input.iam-inline-policy-blocked-kms-actions-enforcement-level
    locals {
        policy_block = core::jsondecode(attrs.policy)
        statements = core::try(local.policy_block.Statement, [])
        
        violations = [
            for statement in local.statements : statement
            if (core::try(statement.Effect, "") == "Allow" &&
                core::try(statement.Resource, "") == "*" &&
                core::length([
                    for action in core::try(statement.Action, []) : action
                    if core::contains(core::split(",", input.blocked_action_pattern), action)
                ]) > 0
            )
        ]
        has_violations = core::length(local.violations) > 0
    }

    enforce {
        condition = !local.has_violations
        error_message = "IAM user policy allows blocked KMS actions on all keys"
    }
}

resource_policy "aws_iam_role_policy" "iam-inline-blocked-kms-actions-role" {
    enforcement_level = input.iam-inline-policy-blocked-kms-actions-enforcement-level
    locals {
        policy_block = core::jsondecode(attrs.policy)
        statements = core::try(local.policy_block.Statement, [])
        
        violations = [
            for statement in local.statements : statement
            if (core::try(statement.Effect, "") == "Allow" &&
                core::try(statement.Resource, "") == "*" &&
                core::length([
                    for action in core::try(statement.Action, []) : action
                    if core::contains(core::split(",", input.blocked_action_pattern), action)
                ]) > 0
            )
        ]
        has_violations = core::length(local.violations) > 0
    }

    enforce {
        condition = !local.has_violations
        error_message = "IAM role policy allows blocked KMS actions on all keys"
    }
}

resource_policy "aws_iam_group_policy" "iam-inline-blocked-kms-actions-group" {
    enforcement_level = input.iam-inline-policy-blocked-kms-actions-enforcement-level
    locals {
        policy_block = core::jsondecode(attrs.policy)
        statements = core::try(local.policy_block.Statement, [])
        
        violations = [
            for statement in local.statements : statement
            if (core::try(statement.Effect, "") == "Allow" &&
                core::try(statement.Resource, "") == "*" &&
                core::length([
                    for action in core::try(statement.Action, []) : action
                    if core::contains(core::split(",", input.blocked_action_pattern), action)
                ]) > 0
            )
        ]
        has_violations = core::length(local.violations) > 0
    }

    enforce {
        condition = !local.has_violations
        error_message = "IAM group policy allows blocked KMS actions on all keys"
    }
}