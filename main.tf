terraform {
  required_version = ">= 1.15.0"

  cloud {
    
    organization = "nagateja-test-org"

    workspaces {
      name = "prewritten-fsbp-testing"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


# ============================================================
# Kinesis
# Policies check: retention_period, encryption_type, kms_key_id
# ============================================================

resource "aws_kinesis_stream" "example" {
  name             = "example-stream"
  shard_count      = 1
  retention_period = 168                  # checked
  encryption_type  = "KMS"               # checked
  kms_key_id       = "alias/aws/kinesis"  # checked
}


# ============================================================
# KMS
# Policies check: deletion_window_in_days, is_enabled,
#                 enable_key_rotation
# ============================================================

resource "aws_kms_key" "example" {
  description             = "example-kms-key"
  enable_key_rotation     = true          # checked
  is_enabled              = true          # checked
  deletion_window_in_days = 30            # checked
}

