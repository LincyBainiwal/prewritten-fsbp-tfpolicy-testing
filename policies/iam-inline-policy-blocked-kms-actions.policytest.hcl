# Copyright IBM Corp. 2026

policytest {
    targets = [
        "iam-inline-policy-blocked-kms-actions.policy.hcl"
    ]
}

# Test 1: PASS - IAM user policy with kms:Decrypt on specific key ARN
resource "aws_iam_user_policy" "pass_user_specific_key" {
  attrs = {
    user = "test-user"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    }
  ]
}
EOT
  }
}

# Test 2: FAIL - IAM user policy with kms:Decrypt on all keys
resource "aws_iam_user_policy" "fail_user_decrypt_all_keys" {
  expect_failure = true
  attrs = {
    user = "test-user"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "*"
    }
  ]
}
EOT
  }
}

# Test 3: PASS - IAM role policy with kms:ReEncryptFrom on specific key ARN
resource "aws_iam_role_policy" "pass_role_specific_key" {
  attrs = {
    role = "test-role"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:ReEncryptFrom"
      ],
      "Resource": "arn:aws:kms:us-west-2:123456789012:key/abcdef12-3456-7890-abcd-ef1234567890"
    }
  ]
}
EOT
  }
}

# Test 4: FAIL - IAM role policy with kms:ReEncryptFrom on all keys
resource "aws_iam_role_policy" "fail_role_reencrypt_all_keys" {
  expect_failure = true
  attrs = {
    role = "test-role"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:ReEncryptFrom"
      ],
      "Resource": "*"
    }
  ]
}
EOT
  }
}

# Test 5: PASS - IAM group policy with both actions on specific keys
resource "aws_iam_group_policy" "pass_group_specific_keys" {
  attrs = {
    group = "test-group"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:ReEncryptFrom"
      ],
      "Resource": [
        "arn:aws:kms:us-east-1:123456789012:key/key1",
        "arn:aws:kms:us-east-1:123456789012:key/key2"
      ]
    }
  ]
}
EOT
  }
}

# Test 6: FAIL - IAM group policy with kms:* wildcard on all keys
resource "aws_iam_group_policy" "fail_group_wildcard_all_keys" {
  expect_failure = true
  attrs = {
    group = "test-group"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:*"
      ],
      "Resource": "*"
    }
  ]
}
EOT
  }
}

# Test 7: PASS - IAM user policy with kms:Encrypt (not a blocked action) on all keys
resource "aws_iam_user_policy" "pass_user_encrypt_all_keys" {
  attrs = {
    user = "test-user"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt"
      ],
      "Resource": "*"
    }
  ]
}
EOT
  }
}

# Test 8: FAIL - IAM role policy with kms:Decrypt as single string on all keys
resource "aws_iam_role_policy" "fail_role_decrypt_string_all_keys" {
  expect_failure = true
  attrs = {
    role = "test-role"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "*"
    }
  ]
}
EOT
  }
}

# Test 9: PASS - IAM group policy with kms:Decrypt on multiple specific ARNs
resource "aws_iam_group_policy" "pass_group_multiple_specific_arns" {
  attrs = {
    group = "test-group"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": [
        "arn:aws:kms:us-east-1:123456789012:key/key1",
        "arn:aws:kms:us-east-1:123456789012:key/key2",
        "arn:aws:kms:us-west-2:123456789012:key/key3"
      ]
    }
  ]
}
EOT
  }
}

# Test 10: PASS - IAM user policy with Deny effect and kms:Decrypt on all keys
resource "aws_iam_user_policy" "pass_user_deny_decrypt_all_keys" {
  attrs = {
    user = "test-user"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "*"
    }
  ]
}
EOT
  }
}

# Test 11: FAIL - IAM role policy with multiple actions including kms:Decrypt on all keys
resource "aws_iam_role_policy" "fail_role_multiple_actions_with_decrypt" {
  expect_failure = true
  attrs = {
    role = "test-role"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:ListKeys"
      ],
      "Resource": "*"
    }
  ]
}
EOT
  }
}

# Test 12: FAIL - IAM user policy with kms:* wildcard on all keys
resource "aws_iam_user_policy" "fail_user_kms_wildcard_all_keys" {
  expect_failure = true
  attrs = {
    user = "test-user"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:*"
      ],
      "Resource": "*"
    }
  ]
}
EOT
  }
}

# Test 13: PASS - IAM role policy with kms:Decrypt on specific key (not wildcard resource)
resource "aws_iam_role_policy" "pass_role_decrypt_specific_key" {
  attrs = {
    role = "test-role"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "arn:aws:kms:us-east-1:123456789012:key/specific-key-id"
    }
  ]
}
EOT
  }
}

# Test 14: FAIL - IAM group policy with kms:ReEncrypt* pattern matching on all keys
resource "aws_iam_group_policy" "fail_group_reencrypt_pattern_all_keys" {
  expect_failure = true
  attrs = {
    group = "test-group"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:ReEncryptFrom"
      ],
      "Resource": "*"
    }
  ]
}
EOT
  }
}

# Test 15: PASS - IAM user policy with mixed actions (blocked on specific, non-blocked on all)
resource "aws_iam_user_policy" "pass_user_mixed_actions" {
  attrs = {
    user = "test-user"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "arn:aws:kms:us-east-1:123456789012:key/key1"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:ListKeys"
      ],
      "Resource": "*"
    }
  ]
}
EOT
  }
}

# Test 16: PASS - kms:* on specific key (should pass since resource is not wildcard)
resource "aws_iam_role_policy" "pass_role_wildcard_specific_key" {
  attrs = {
    role = "test-role"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:*"
      ],
      "Resource": "arn:aws:kms:us-east-1:123456789012:key/specific-key-id"
    }
  ]
}
EOT
  }
}

# Test 17: FAIL - Multiple blocked actions together on all keys
resource "aws_iam_group_policy" "fail_group_multiple_blocked_all_keys" {
  expect_failure = true
  attrs = {
    group = "test-group"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:ReEncryptFrom"
      ],
      "Resource": "*"
    }
  ]
}
EOT
  }
}

# Test 18: PASS - Empty Action array (edge case)
resource "aws_iam_user_policy" "pass_user_empty_actions" {
  attrs = {
    user = "test-user"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [],
      "Resource": "*"
    }
  ]
}
EOT
  }
}