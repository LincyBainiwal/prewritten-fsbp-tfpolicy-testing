# Copyright IBM Corp. 2026

# RDS DB Instances should prohibit public access, as determined by the PubliclyAccessible configuration

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-instance-public-access-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_db_instance" "public_access_prohibited" {
    enforcement_level = input.rds-instance-public-access-check-enforcement-level
    enforce {
        condition = core::try(attrs.publicly_accessible, false) == false
        error_message = "RDS DB Instance should prohibit public access"
    }
}
