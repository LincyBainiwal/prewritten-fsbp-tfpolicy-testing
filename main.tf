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

# resource "aws_route53_zone" "example" {                         # ✅ applied & destroyed
#   name = "example-778091236250.com"
# }

# resource "aws_cloudwatch_log_group" "route53_query_logs" {      # ✅ applied & destroyed
#   name              = "/aws/route53/example-778091236250.com"
#   retention_in_days = 90
# }

# resource "aws_cloudwatch_log_resource_policy" "route53_query_logs" {  # ✅ applied & destroyed
#   policy_name = "route53-query-logging-policy"
#   policy_document = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Sid    = "Route53LogsToCloudWatchLogs"
#       Effect = "Allow"
#       Principal = { Service = "route53.amazonaws.com" }
#       Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
#       Resource = "${aws_cloudwatch_log_group.route53_query_logs.arn}:*"
#     }]
#   })
# }

# resource "aws_route53_query_log" "example" {                    # ✅ applied & destroyed
#   zone_id                  = aws_route53_zone.example.zone_id
#   cloudwatch_log_group_arn = aws_cloudwatch_log_group.route53_query_logs.arn
#   depends_on = [aws_cloudwatch_log_resource_policy.route53_query_logs]
# }





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





# ============================================================
# S3
# Policies check: bucket (name), acl, access_control_policy,
#                 block_public_acls, block_public_policy,
#                 ignore_public_acls, restrict_public_buckets,
#                 policy (JSON - no blacklisted actions),
#                 details[0].public_access_block (MRAP),
#                 lifecycle_rule (bucket lifecycle check)
# ============================================================

# resource "aws_s3_bucket" "example" {               # ✅ applied & destroyed
#   bucket = "example-bucket-778091236250"
# }

# resource "aws_s3_bucket_public_access_block" "example" {
#   bucket                  = aws_s3_bucket.example.id
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# #aws_s3_bucket_acl removed: s3-bucket-acl-prohibited flags any bucket with acl resource

# resource "aws_s3_bucket_lifecycle_configuration" "example" {
#   bucket = aws_s3_bucket.example.id
#   rule {
#     id     = "example-rule"
#     status = "Enabled"
#     expiration {
#       days = 365
#     }
#   }
# }

# resource "aws_s3_bucket_logging" "example" {
#   bucket        = aws_s3_bucket.example.id
#   target_bucket = aws_s3_bucket.example.id
#   target_prefix = "access-logs/"
# }

# resource "aws_s3_bucket_policy" "example" {
#   bucket = aws_s3_bucket.example.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Sid       = "DenyNonSSL"
#       Effect    = "Deny"
#       Principal = "*"
#       Action    = "s3:*"
#       Resource  = [
#         "arn:aws:s3:::example-bucket-778091236250",
#         "arn:aws:s3:::example-bucket-778091236250/*"
#       ]
#       Condition = {
#         Bool = { "aws:SecureTransport" = "false" }
#       }
#     }]
#   })
# }

# resource "aws_s3_account_public_access_block" "example" {
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# resource "aws_s3_access_point" "example" {
#   bucket = aws_s3_bucket.example.id
#   name   = "example-access-point"
#   public_access_block_configuration {
#     block_public_acls       = true
#     block_public_policy     = true
#     ignore_public_acls      = true
#     restrict_public_buckets = true
#   }
# }

# resource "aws_s3control_multi_region_access_point" "example" {
#   details {
#     name = "example-mrap"
#     region {
#       bucket = aws_s3_bucket.example.id
#     }
#     public_access_block {
#       block_public_acls       = true
#       block_public_policy     = true
#       ignore_public_acls      = true
#       restrict_public_buckets = true
#     }
#   }
# }

# resource "aws_s3_directory_bucket" "example" {      # ✅ applied & destroyed
#   bucket = "example-bucket--use1-az4--x-s3"
#   location {
#     name = "use1-az4"
#   }
# }

# resource "aws_s3_bucket_lifecycle_configuration" "directory_bucket" {
#   bucket = aws_s3_directory_bucket.example.bucket
#   rule {
#     id     = "dir-bucket-expiry"
#     status = "Enabled"
#     expiration {
#       days = 30
#     }
#   }
# }






# ============================================================
# SES
# Policies check: delivery_options (tls_policy = REQUIRE)
# ============================================================

# resource "aws_ses_configuration_set" "example" {
#   name = "example-config-set"
#   delivery_options {
#     tls_policy = "Require"               # checked
#   }
# }

# resource "aws_sesv2_configuration_set" "example" {
#   configuration_set_name = "example-v2-config-set"
#   delivery_options {
#     tls_policy = "REQUIRE"               # checked
#   }
# }





# # ============================================================
# # SNS
# # Policies check: policy (JSON - no public principal *),
# #                 topic inline policy
# # ============================================================

# resource "aws_sns_topic" "example" {
#   name   = "example-topic"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect    = "Allow"
#       Principal = { AWS = "arn:aws:iam::778091236250:root" }
#       Action    = "SNS:Publish"
#       Resource  = "arn:aws:sns:us-east-1:778091236250:example-topic"
#     }]
#   })
# }

# resource "aws_sns_topic_policy" "example" {
#   arn = aws_sns_topic.example.arn
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect    = "Allow"
#       Principal = { AWS = "arn:aws:iam::778091236250:root" }
#       Action    = "SNS:Publish"
#       Resource  = aws_sns_topic.example.arn
#     }]
#   })
# }





# # ============================================================
# # SQS
# # Policies check: sqs_managed_sse_enabled, kms_master_key_id,
# #                 policy (no public * access)
# # ============================================================

# resource "aws_sqs_queue" "example" {
#   name              = "example-queue"
#   kms_master_key_id = "alias/aws/sqs"
# }

# resource "aws_sqs_queue_policy" "example" {
#   queue_url = aws_sqs_queue.example.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect    = "Allow"
#       Principal = { AWS = "arn:aws:iam::778091236250:root" }
#       Action    = "sqs:SendMessage"
#       Resource  = aws_sqs_queue.example.arn
#     }]
#   })
# }





# # ============================================================
# # SSM
# # Policies check:
# #   ssm-document-not-public            → aws_ssm_document: permissions must not contain "All" in account_ids
# #   ssm-automation-block-public-sharing → aws_ssm_service_setting: setting_id = exact path, setting_value = "Disable"
# #   ssm-automation-logging-enabled     → aws_ssm_service_setting: non-empty setting_value
# #                                        aws_cloudwatch_log_group: non-empty name
# # ============================================================

# resource "aws_ssm_document" "example" {
#   name          = "example-document"
#   document_type = "Command"
#   content = jsonencode({
#     schemaVersion = "2.2"
#     description   = "Example SSM document"
#     mainSteps = [{
#       action = "aws:runShellScript"
#       name   = "runScript"
#       inputs = { runCommand = ["echo hello"] }
#     }]
#   })
# }

# resource "aws_ssm_service_setting" "block_sharing" {
#   setting_id    = "/ssm/documents/console/public-sharing-permission"
#   setting_value = "Disable"
# }

# resource "aws_ssm_service_setting" "logging" {
#   setting_id    = "arn:aws:ssm:us-east-1:778091236250:servicesetting/ssm/automation/customer-script-log-destination"
#   setting_value = "CloudWatch"
# }

# resource "aws_cloudwatch_log_group" "ssm_automation" {
#   name              = "/aws/ssm/automation/executeScript"
#   retention_in_days = 7
# }





# ============================================================
# Neptune
# Policies check: backup_retention_period, enable_cloudwatch_logs_exports,
#                 copy_tags_to_snapshot, deletion_protection,
#                 storage_encrypted, kms_key_arn,
#                 iam_database_authentication_enabled,
#                 (snapshot) storage_encrypted
# ============================================================

# resource "aws_neptune_subnet_group" "example" {
#   name       = "example-neptune-subnet-group"
#   subnet_ids = [
#     "subnet-00b29a1440b8967e9",  # us-east-1a
#     "subnet-048cfe24c2f869a51",  # us-east-1b
#     "subnet-032dfcd262262bc16",  # us-east-1c
#   ]
# }

# resource "aws_neptune_cluster" "example" {
#   cluster_identifier                  = "example-neptune"
#   engine                              = "neptune"
#   backup_retention_period             = 7          # checked
#   deletion_protection                 = false      # false for easy destroy
#   storage_encrypted                   = true       # checked
#   iam_database_authentication_enabled = true       # checked
#   copy_tags_to_snapshot               = true       # checked
#   enable_cloudwatch_logs_exports      = ["audit"]  # checked
#   skip_final_snapshot                 = true
#   neptune_subnet_group_name           = aws_neptune_subnet_group.example.name
#   vpc_security_group_ids              = ["sg-0f755fef803db65d1"]
# }

# resource "aws_neptune_cluster_instance" "example" {
#   cluster_identifier = aws_neptune_cluster.example.id
#   instance_class     = "db.t3.medium"
#   engine             = "neptune"
# }

# resource "aws_neptune_cluster_snapshot" "example" {
#   db_cluster_identifier          = aws_neptune_cluster.example.id
#   db_cluster_snapshot_identifier = "example-neptune-snapshot"
# }




# ============================================================
# Network Firewall
# Policies check: delete_protection, subnet_change_protection,
#                 logging_configuration (log_destination_config),
#                 firewall_policy (stateless_default_actions,
#                 stateless_fragment_default_actions,
#                 stateless_rule_group_reference),
#                 rule_group (type=STATELESS, stateless_rule list)
# ============================================================

# resource "aws_networkfirewall_rule_group" "example" {    # ✅ applied & destroyed
#   capacity = 100
#   name     = "example-rule-group"
#   type     = "STATELESS"
#   rule_group {
#     rules_source {
#       stateless_rules_and_custom_actions {
#         stateless_rule {
#           priority = 1
#           rule_definition {
#             actions = ["aws:pass"]
#             match_attributes {
#               source      { address_definition = "0.0.0.0/0" }
#               destination { address_definition = "0.0.0.0/0" }
#             }
#           }
#         }
#       }
#     }
#   }
# }

# resource "aws_networkfirewall_firewall_policy" "example" {  # ✅ applied & destroyed
#   name = "example-firewall-policy"
#   firewall_policy {
#     stateless_default_actions          = ["aws:forward_to_sfe"]
#     stateless_fragment_default_actions = ["aws:forward_to_sfe"]
#     stateless_rule_group_reference {
#       priority     = 1
#       resource_arn = aws_networkfirewall_rule_group.example.arn
#     }
#   }
# }

# resource "aws_cloudwatch_log_group" "network_firewall" {   # ✅ applied & destroyed
#   name              = "/aws/network-firewall/example"
#   retention_in_days = 90
# }

# TEMP: uncommented to disable delete_protection before destroy
resource "aws_networkfirewall_firewall" "example" {
  name                     = "example-firewall"
  firewall_policy_arn      = aws_networkfirewall_firewall_policy.example.arn
  vpc_id                   = "vpc-0cea84131196c634c"
  delete_protection        = false              # ← changed from true so destroy works
  subnet_change_protection = false              # ← changed from true so destroy works
  subnet_mapping {
    subnet_id = "subnet-00b29a1440b8967e9"
  }
}

resource "aws_networkfirewall_firewall_policy" "example" {
  name = "example-firewall-policy"
  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateless_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.example.arn
    }
  }
}

resource "aws_networkfirewall_rule_group" "example" {
  capacity = 100
  name     = "example-rule-group"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:pass"]
            match_attributes {
              source      { address_definition = "0.0.0.0/0" }
              destination { address_definition = "0.0.0.0/0" }
            }
          }
        }
      }
    }
  }
}

# resource "aws_networkfirewall_logging_configuration" "example" {  # ✅ applied & destroyed
#   firewall_arn = aws_networkfirewall_firewall.example.arn
#   logging_configuration {
#     log_destination_config {
#       log_destination      = { logGroup = "/aws/network-firewall/example" }
#       log_destination_type = "CloudWatchLogs"
#       log_type             = "FLOW"
#     }
#   }
# }







# ============================================================
# IAM
# Policies check: source_identifier, owner, input_parameters,
#                 require_uppercase_characters,
#                 require_lowercase_characters, require_symbols,
#                 require_numbers, minimum_password_length,
#                 password_reuse_prevention, max_password_age,
#                 policy (JSON), user, policy_arn
# ============================================================

# resource "aws_config_config_rule" "access_keys" {
#   name = "access-keys-rotated"            # checked: exact name
#   source {
#     owner             = "AWS"             # checked
#     source_identifier = "ACCESS_KEYS_ROTATED"  # checked
#   }
#   input_parameters = jsonencode({ maxAccessKeyAge = "90" })  # checked
# }

# resource "aws_config_config_rule" "unused_credentials" {
#   name = "iam-user-unused-credentials-check"  # checked: exact name
#   source {
#     owner             = "AWS"             # checked
#     source_identifier = "IAM_USER_UNUSED_CREDENTIALS_CHECK"  # checked
#   }
#   input_parameters = jsonencode({ maxCredentialUsageAge = "90" })  # checked
# }

# resource "aws_iam_account_password_policy" "example" {
#   minimum_password_length      = 14       # checked
#   require_uppercase_characters = true     # checked
#   require_lowercase_characters = true     # checked
#   require_numbers              = true     # checked
#   require_symbols              = true     # checked
#   max_password_age             = 90       # checked
#   password_reuse_prevention    = 24       # checked
# }

# resource "aws_iam_policy" "example" {
#   name = "example-policy"                 # checked
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect   = "Allow"
#       Action   = ["s3:GetObject"]         # checked: no wildcards like s3:*
#       Resource = "*"
#     }]
#   })
# }

# resource "aws_iam_role_policy" "example" {
#   name = "example-role-policy"
#   role = "example-role"
#   policy = jsonencode({                   # checked
#     Version = "2012-10-17"
#     Statement = [{
#       Effect   = "Allow"
#       Action   = ["s3:GetObject"]
#       Resource = "*"
#     }]
#   })
# }

# resource "aws_iam_user_policy" "example" {
#   name = "example-user-policy"
#   user = "example-user"                   # checked
#   policy = jsonencode({                   # checked
#     Version = "2012-10-17"
#     Statement = [{
#       Effect   = "Allow"
#       Action   = ["s3:GetObject"]
#       Resource = "*"
#     }]
#   })
# }

# resource "aws_iam_group_policy" "example" {
#   name  = "example-group-policy"
#   group = "example-group"
#   policy = jsonencode({                   # checked
#     Version = "2012-10-17"
#     Statement = [{
#       Effect   = "Allow"
#       Action   = ["s3:GetObject"]
#       Resource = "*"
#     }]
#   })
# }

# resource "aws_iam_access_key" "example" {
#   user = "example-user"                   # checked: not "root"
# }

# resource "aws_iam_user_policy_attachment" "example" {
#   user       = "example-user"             # checked
#   policy_arn = aws_iam_policy.example.arn # checked
# }

# # ============================================================
# # Inspector
# # Policies check: resource_types (list), auto_enable block
# #                 (ec2, ecr, lambda, lambda_code)
# # ============================================================

# resource "aws_inspector2_enabler" "example" {
#   account_ids    = ["123456789012"]
#   resource_types = ["EC2", "ECR", "LAMBDA", "LAMBDA_CODE"]  # checked
# }

# resource "aws_inspector2_organization_configuration" "example" {
#   auto_enable {                           # checked
#     ec2         = true                   # checked
#     ecr         = true                   # checked
#     lambda      = true                   # checked
#     lambda_code = true                   # checked
#   }
# }




# # ============================================================
# # Macie
# # Policies check: status
# # ============================================================

# resource "aws_macie2_account" "example" {
#   finding_publishing_frequency = "FIFTEEN_MINUTES"
#   status                       = "ENABLED"  # checked
# }

# # ============================================================
# # MQ
# # Policies check: engine_type (ActiveMQ), logs.audit
# # ============================================================

# resource "aws_mq_broker" "example" {
#   broker_name         = "example-broker"
#   engine_type         = "ActiveMQ"        # checked: policy filters on ActiveMQ
#   engine_version      = "5.17.6"
#   host_instance_type  = "mq.m5.large"
#   publicly_accessible = false

#   user {
#     username = "admin"
#     password = "Admin1234!XyZ"
#   }

#   logs {
#     audit = true                          # checked
#   }
# }
