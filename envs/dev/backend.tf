terraform {
  backend "s3" {
    key          = "envs/dev/terraform.tfstate"
    use_lockfile = true
    encrypt      = true
  }
}