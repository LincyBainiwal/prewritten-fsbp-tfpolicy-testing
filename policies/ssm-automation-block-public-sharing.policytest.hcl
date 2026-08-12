# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ssm-automation-block-public-sharing.policy.hcl"
    ]
}

# Test 1: PASS - SSM service setting with public sharing disabled (correct setting_id and value)
resource "aws_ssm_service_setting" "pass_public_sharing_disabled" {
  attrs = {
    setting_id = "/ssm/documents/console/public-sharing-permission"
    setting_value = "Disable"
  }
}

# Test 2: FAIL - SSM service setting with public sharing enabled (value is "Enable")
resource "aws_ssm_service_setting" "fail_public_sharing_enabled" {
  expect_failure = true
  attrs = {
    setting_id = "/ssm/documents/console/public-sharing-permission"
    setting_value = "Enable"
  }
}

# Test 3: FAIL - Wrong setting_id (not the public sharing permission setting)
resource "aws_ssm_service_setting" "fail_wrong_setting_id" {
  expect_failure = true
  attrs = {
    setting_id = "/ssm/managed-instance/activation-tier"
    setting_value = "Disable"
  }
}

# Test 4: FAIL - Empty setting_id
resource "aws_ssm_service_setting" "fail_empty_setting_id" {
  expect_failure = true
  attrs = {
    setting_id = ""
    setting_value = "Disable"
  }
}

# Test 5: FAIL - Missing setting_id attribute
resource "aws_ssm_service_setting" "fail_missing_setting_id" {
  expect_failure = true
  attrs = {
    setting_value = "Disable"
  }
}

# Test 6: FAIL - Correct setting_id but empty setting_value
resource "aws_ssm_service_setting" "fail_empty_setting_value" {
  expect_failure = true
  attrs = {
    setting_id = "/ssm/documents/console/public-sharing-permission"
    setting_value = ""
  }
}

# Test 7: FAIL - Correct setting_id but missing setting_value
resource "aws_ssm_service_setting" "fail_missing_setting_value" {
  expect_failure = true
  attrs = {
    setting_id = "/ssm/documents/console/public-sharing-permission"
  }
}

# Test 8: FAIL - Correct setting_id but wrong value (not "Disable")
resource "aws_ssm_service_setting" "fail_wrong_value" {
  expect_failure = true
  attrs = {
    setting_id = "/ssm/documents/console/public-sharing-permission"
    setting_value = "Allow"
  }
}

# Test 9: FAIL - Both setting_id and setting_value are wrong
resource "aws_ssm_service_setting" "fail_both_wrong" {
  expect_failure = true
  attrs = {
    setting_id = "/ssm/other/setting"
    setting_value = "Enable"
  }
}

# Test 10: FAIL - Case sensitivity test - "disable" instead of "Disable"
resource "aws_ssm_service_setting" "fail_case_sensitive_value" {
  expect_failure = true
  attrs = {
    setting_id = "/ssm/documents/console/public-sharing-permission"
    setting_value = "disable"
  }
}
