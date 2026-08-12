# Copyright IBM Corp. 2026

policytest {
  targets = ["iam-user-unused-credentials-check.policy.hcl"]
}
# Test 1: AWS Config rule with correct configuration (PASS)
resource "aws_config_config_rule" "config_rule_properly_configured" {
  attrs = {
    name = "iam-user-unused-credentials-check"
    source = [{
      owner = "AWS"
      source_identifier = "IAM_USER_UNUSED_CREDENTIALS_CHECK"
    }]
    input_parameters = "{\"maxCredentialUsageAge\":\"90\"}"
  }
}

# Test 2: AWS Config rule with incorrect source identifier (FAIL)
resource "aws_config_config_rule" "config_rule_wrong_source_identifier" {
  expect_failure = true
  attrs = {
    name = "iam-user-unused-credentials-check"
    source = [{
      owner = "AWS"
      source_identifier = "WRONG_IDENTIFIER"
    }]
    input_parameters = "{\"maxCredentialUsageAge\":\"90\"}"
  }
}

# Test 3: AWS Config rule with non-AWS owner (FAIL)
resource "aws_config_config_rule" "config_rule_not_aws_managed" {
  expect_failure = true
  attrs = {
    name = "iam-user-unused-credentials-check"
    source = [{
      owner = "CUSTOM_LAMBDA"
      source_identifier = "IAM_USER_UNUSED_CREDENTIALS_CHECK"
    }]
    input_parameters = "{\"maxCredentialUsageAge\":\"90\"}"
  }
}

# Test 4: AWS Config rule with both correct source and AWS owner (PASS)
resource "aws_config_config_rule" "config_rule_fully_compliant" {
  attrs = {
    name = "iam-user-unused-credentials-check"
    source = [{
      owner = "AWS"
      source_identifier = "IAM_USER_UNUSED_CREDENTIALS_CHECK"
    }]
    input_parameters = "{\"maxCredentialUsageAge\":\"90\"}"
  }
}

# Test 5: AWS Config rule with unsupported maxCredentialUsageAge override (FAIL)
resource "aws_config_config_rule" "config_rule_wrong_max_age" {
  expect_failure = true
  attrs = {
    name = "iam-user-unused-credentials-check"
    source = [{
      owner = "AWS"
      source_identifier = "IAM_USER_UNUSED_CREDENTIALS_CHECK"
    }]
    input_parameters = "{\"maxCredentialUsageAge\":\"60\"}"
  }
}

# Test 6: AWS Config rule with wrong source and wrong owner (FAIL - multiple violations)
resource "aws_config_config_rule" "config_rule_multiple_violations" {
  expect_failure = true
  attrs = {
    name = "iam-user-unused-credentials-check"
    source = [{
      owner = "CUSTOM"
      source_identifier = "WRONG_SOURCE"
    }]
  }
}