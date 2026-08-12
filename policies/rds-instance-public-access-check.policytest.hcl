# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-instance-public-access-check.policy.hcl"
    ]
}

# Test 1: PASS - publicly_accessible is false
resource "aws_db_instance" "pass_publicly_accessible_false" {
    attrs = {
        publicly_accessible = false
    }
}

# Test 2: FAIL - publicly_accessible is true
resource "aws_db_instance" "fail_publicly_accessible_true" {
    expect_failure = true
    attrs = {
        publicly_accessible = true
    }
}

# Test 3: PASS - publicly_accessible is not present (default is false)
resource "aws_db_instance" "fail_publicly_accessible_missing" {
    attrs = {}
}
