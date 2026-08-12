# Copyright IBM Corp. 2026

policytest {
  targets = ["iam-policy-no-statements-with-admin-access.policy.hcl"]
}

resource "aws_iam_policy" "managed_policy_allows_admin" {
  expect_failure = true
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/managed-admin-policy"
    name   = "managed-admin-policy"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"Resource\":\"*\"}]}"
  }
}

resource "aws_iam_policy" "managed_policy_read_only" {
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/managed-readonly-policy"
    name   = "managed-readonly-policy"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"s3:GetObject\"],\"Resource\":[\"arn:aws:s3:::example-bucket/*\"]}]}"
  }
}

resource "aws_iam_policy" "managed_policy_admin_action_list" {
  expect_failure = true
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/managed-admin-action-list"
    name   = "managed-admin-action-list"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"*\"],\"Resource\":\"*\"}]}"
  }
}

resource "aws_iam_policy" "managed_policy_admin_resource_list" {
  expect_failure = true
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/managed-admin-resource-list"
    name   = "managed-admin-resource-list"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"Resource\":[\"*\"]}]}"
  }
}

resource "aws_iam_policy" "managed_policy_deny_admin" {
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/managed-deny-admin"
    name   = "managed-deny-admin"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Action\":\"*\",\"Resource\":\"*\"}]}"
  }
}

resource "aws_iam_policy" "permissions_boundary_policy_admin" {
  expect_failure = true
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/permissions-boundary-admin"
    name   = "permissions-boundary-admin"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"Resource\":\"*\"}]}"
  }
}

resource "aws_iam_role" "role_with_boundary" {
  attrs = {
    name = "role-with-boundary"
    permissions_boundary = "arn:aws:iam::123456789012:policy/permissions-boundary-admin"
  }
}
