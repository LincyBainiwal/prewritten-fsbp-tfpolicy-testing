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

# resource "aws_kinesis_stream" "example" {
#   name             = "example-stream"
#   shard_count      = 1
#   retention_period = 168                  # checked
#   encryption_type  = "KMS"               # checked
#   kms_key_id       = "alias/aws/kinesis"  # checked
# }


# ============================================================
# KMS
# Policies check: deletion_window_in_days, is_enabled,
#                 enable_key_rotation
# ============================================================

# resource "aws_kms_key" "example" {
#   description             = "example-kms-key"
#   enable_key_rotation     = true          # checked
#   is_enabled              = true          # checked
#   deletion_window_in_days = 30            # checked
# }




# ============================================================
# Route53
# Policies check: vpc (public zone = no vpc block), zone_id, name
# ============================================================

resource "aws_route53_zone" "example" {                         # ✅ applied & destroyed
  name = "example-778091236250.com"
}

resource "aws_cloudwatch_log_group" "route53_query_logs" {      # ✅ applied & destroyed
  name              = "/aws/route53/example-778091236250.com"
  retention_in_days = 90
}

resource "aws_cloudwatch_log_resource_policy" "route53_query_logs" {  # ✅ applied & destroyed
  policy_name = "route53-query-logging-policy"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "Route53LogsToCloudWatchLogs"
      Effect = "Allow"
      Principal = { Service = "route53.amazonaws.com" }
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "${aws_cloudwatch_log_group.route53_query_logs.arn}:*"
    }]
  })
}

resource "aws_route53_query_log" "example" {                    # ✅ applied & destroyed
  zone_id                  = aws_route53_zone.example.zone_id
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.route53_query_logs.arn
  depends_on = [aws_cloudwatch_log_resource_policy.route53_query_logs]
}

