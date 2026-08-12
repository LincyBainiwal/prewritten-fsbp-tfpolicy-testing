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





# ============================================================
# OpenSearch
# Policies check: advanced_security_options (enabled),
#                 log_publishing_options, cluster_config
#                 (instance_count, zone_awareness),
#                 encrypt_at_rest (enabled), engine_version,
#                 domain_endpoint_options (enforce_https,
#                 tls_security_policy), vpc_options,
#                 node_to_node_encryption (enabled),
#                 software_update_options
# ============================================================

# resource "aws_cloudwatch_log_group" "opensearch" {
#   name              = "/aws/opensearch/example"
#   retention_in_days = 90
# }

# resource "aws_cloudwatch_log_resource_policy" "opensearch" {
#   policy_name = "opensearch-log-policy"
#   policy_document = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect    = "Allow"
#       Principal = { Service = "es.amazonaws.com" }
#       Action    = ["logs:PutLogEvents", "logs:CreateLogStream"]
#       Resource  = "${aws_cloudwatch_log_group.opensearch.arn}:*"
#     }]
#   })
# }

# # aws_iam_service_linked_role.opensearch skipped — already exists in account
# resource "aws_opensearch_domain" "example" {
#   domain_name    = "example-domain"
#   engine_version = "OpenSearch_2.11"     # checked

#   cluster_config {                       # checked
#     instance_type          = "t3.small.search"
#     instance_count         = 3           # checked: >= 3
#     zone_awareness_enabled = true
#     zone_awareness_config {
#       availability_zone_count = 3
#     }
#   }

#   ebs_options {
#     ebs_enabled = true
#     volume_size = 10                     # required for t3.small.search
#   }

#   encrypt_at_rest {
#     enabled = true                       # checked
#   }

#   node_to_node_encryption {
#     enabled = true                       # checked
#   }

#   domain_endpoint_options {
#     enforce_https       = true           # checked
#     tls_security_policy = "Policy-Min-TLS-1-2-PFS-2023-10"  # checked
#   }

#   advanced_security_options {            # checked
#     enabled                        = true
#     anonymous_auth_enabled         = false
#     internal_user_database_enabled = true
#     master_user_options {
#       master_user_name     = "admin"
#       master_user_password = "Admin1234!"
#     }
#   }

#   vpc_options {                          # checked
#     subnet_ids = [
#       "subnet-00b29a1440b8967e9",        # us-east-1a
#       "subnet-048cfe24c2f869a51",        # us-east-1b
#       "subnet-032dfcd262262bc16",        # us-east-1c
#     ]
#     security_group_ids = ["sg-0f755fef803db65d1"]
#   }

#   log_publishing_options {               # checked: audit logging
#     cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
#     log_type                 = "AUDIT_LOGS"
#     enabled                  = true
#   }

#   log_publishing_options {
#     cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
#     log_type                 = "ES_APPLICATION_LOGS"
#     enabled                  = true
#   }

#   log_publishing_options {
#     cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
#     log_type                 = "INDEX_SLOW_LOGS"
#     enabled                  = true
#   }

#   software_update_options {             # checked
#     auto_software_update_enabled = true
#   }

#   depends_on = [aws_cloudwatch_log_resource_policy.opensearch]
# }




