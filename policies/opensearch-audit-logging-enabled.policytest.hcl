# Copyright IBM Corp. 2026

policytest {
    targets = [
        "opensearch-audit-logging-enabled.policy.hcl"
    ]
}

# Test 1: PASS - OpenSearch domain with audit logging enabled
resource "aws_opensearch_domain" "pass_audit_logs_enabled" {
  attrs = {
    domain_name = "compliant-domain"
    engine_version = "OpenSearch_2.5"
    log_publishing_options = [
      {
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/opensearch/audit"
        enabled = true
        log_type = "AUDIT_LOGS"
      }
    ]
    advanced_security_options = [
      {
        enabled = true
        internal_user_database_enabled = true
      }
    ]
  }
}

# Test 2: FAIL - OpenSearch domain with audit logging explicitly disabled
resource "aws_opensearch_domain" "fail_audit_logs_disabled" {
  expect_failure = true
  attrs = {
    domain_name = "non-compliant-domain"
    engine_version = "OpenSearch_2.5"
    log_publishing_options = [
      {
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/opensearch/audit"
        enabled = false
        log_type = "AUDIT_LOGS"
      }
    ]
  }
}

# Test 3: FAIL - OpenSearch domain without log_publishing_options
resource "aws_opensearch_domain" "fail_no_log_options" {
  expect_failure = true
  attrs = {
    domain_name = "no-logs-domain"
    engine_version = "OpenSearch_2.5"
  }
}

# Test 4: FAIL - OpenSearch domain with other log types but no AUDIT_LOGS
resource "aws_opensearch_domain" "fail_no_audit_logs" {
  expect_failure = true
  attrs = {
    domain_name = "other-logs-domain"
    engine_version = "OpenSearch_2.5"
    log_publishing_options = [
      {
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/opensearch/index-slow"
        enabled = true
        log_type = "INDEX_SLOW_LOGS"
      },
      {
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/opensearch/search-slow"
        enabled = true
        log_type = "SEARCH_SLOW_LOGS"
      }
    ]
  }
}

# Test 5: PASS - OpenSearch domain with multiple log types including enabled AUDIT_LOGS
resource "aws_opensearch_domain" "pass_multiple_logs_with_audit" {
  attrs = {
    domain_name = "multiple-logs-domain"
    engine_version = "OpenSearch_2.5"
    log_publishing_options = [
      {
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/opensearch/index-slow"
        enabled = true
        log_type = "INDEX_SLOW_LOGS"
      },
      {
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/opensearch/audit"
        enabled = true
        log_type = "AUDIT_LOGS"
      },
      {
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/opensearch/application"
        enabled = true
        log_type = "ES_APPLICATION_LOGS"
      }
    ]
    advanced_security_options = [
      {
        enabled = true
      }
    ]
  }
}

# Test 6: FAIL - OpenSearch domain without log_publishing_options
resource "aws_opensearch_domain" "fail_empty_log_options" {
  expect_failure = true
  attrs = {
    domain_name = "no-logs-domain"
    engine_version = "OpenSearch_2.5"
    log_publishing_options = [{}]
  }
}
