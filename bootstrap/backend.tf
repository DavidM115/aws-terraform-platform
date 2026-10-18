# Backend blocks cannot use variables, so bucket/region live in backend.hcl
# (git-ignored "partial configuration"). Everything non-sensitive and static
# is set here.
# ---------------------------------------------------------------------------

terraform {
  backend "s3" {
    key          = "bootstrap/terraform.tfstate"
    use_lockfile = true
    encrypt      = true
  }
}
