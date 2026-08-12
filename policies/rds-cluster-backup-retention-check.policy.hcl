# Copyright IBM Corp. 2026

# RDS DB clusters should have enough backup retention period set

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-cluster-backup-retention-check-enforcement-level" {
  type = string
  default = "advisory"
}

input "min_backup_retention_period_1" {
    type = number
    default = 7
}

resource_policy "aws_rds_cluster" "cluster_backup_enabled" {
    enforcement_level = input.rds-cluster-backup-retention-check-enforcement-level
    locals {
        backup_period = core::try(attrs.backup_retention_period, 1)
        is_valid_input = input.min_backup_retention_period_1 >= 7 && input.min_backup_retention_period_1 <= 35
    }

    enforce {
        condition = local.backup_period != 0 && local.is_valid_input && local.backup_period >= input.min_backup_retention_period_1
        error_message = "RDS clusters should have enough backup retention period set"
    }
}
