# ------------------------------
# VPC Configuration
# ------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

# ------------------------------
# Public Subnet Configuration
# ------------------------------

# ------------------------------
# Private Subnet Configuration
# ------------------------------
