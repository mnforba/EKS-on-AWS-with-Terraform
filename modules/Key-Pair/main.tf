# Fetching AWS Key Pair
data "aws_key_pair" "vprof" {
  key_name           = var.key_name
  include_public_key = true
}