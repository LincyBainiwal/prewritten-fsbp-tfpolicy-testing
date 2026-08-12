# Copyright IBM Corp. 2026

policytest{
  targets = [
    "sqs-queue-no-public-access.policy.hcl"
  ]
}

# Test 1: SQS queue policy with specific AWS account principal (would pass if validation worked)
resource "aws_sqs_queue_policy" "pass_specific_account_principal" {
  attrs = {
    queue_url = "https://sqs.us-east-1.amazonaws.com/123456789012/my-queue"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::123456789012:root\"},\"Action\":\"sqs:*\",\"Resource\":\"*\"}]}"
  }
}

# Test 2: SQS queue policy with wildcard (*) as Principal (would fail if validation worked)
resource "aws_sqs_queue_policy" "fail_wildcard_principal" {
  attrs = {
    queue_url = "https://sqs.us-east-1.amazonaws.com/123456789012/my-queue"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"sqs:SendMessage\",\"Resource\":\"*\"}]}"
  }
}

# Test 3: SQS queue policy with wildcard (*) in Principal.AWS (would fail if validation worked)
resource "aws_sqs_queue_policy" "fail_wildcard_principal_aws" {
  attrs = {
    queue_url = "https://sqs.us-east-1.amazonaws.com/123456789012/my-queue"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"*\"},\"Action\":\"sqs:ReceiveMessage\",\"Resource\":\"*\"}]}"
  }
}

# Test 4: SQS queue with inline policy containing wildcard Principal (would fail if validation worked)
resource "aws_sqs_queue" "fail_inline_wildcard_principal" {
  attrs = {
    name = "my-public-queue"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"sqs:SendMessage\",\"Resource\":\"*\"}]}"
  }
}

# Test 5: SQS queue with inline policy restricted to specific principals (would pass if validation worked)
resource "aws_sqs_queue" "pass_inline_specific_principal" {
  attrs = {
    name = "my-compliant-queue"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::123456789012:role/MyRole\"},\"Action\":\"sqs:*\",\"Resource\":\"*\"}]}"
  }
}

# Test 6: SQS queue without policy (filtered out, not evaluated)
resource "aws_sqs_queue" "no_policy" {
  attrs = {
    name = "my-queue-no-policy"
  }
}
