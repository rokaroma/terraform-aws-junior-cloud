

terraform {
  backend "s3" {
    bucket       = "romasaso-terraform-state-bucket"
    key          = "prod/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}

