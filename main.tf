terraform {
  cloud {
    organization = "nagateja-test-org"
    workspaces {
      name = "prewritten-testing"
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

