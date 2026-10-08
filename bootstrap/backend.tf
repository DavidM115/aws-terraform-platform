# ---------------------------------------------------------------------------
# PHASE 2 - leave this commented out for the FIRST apply (local state).
#
# After the bucket exists:
#   1. terraform output -raw backend_hcl > backend.hcl
#   2. Uncomment the block below
#   3. terraform init -migrate-state -backend-config=backend.hcl
#
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
