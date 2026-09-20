terraform {
  backend "s3" {
    # Supply these values with -backend-config files per environment.
    # Example: terraform init -backend-config=environments/dev/backend.hcl
    bucket       = ""
    key          = ""
    region       = ""
    use_lockfile = true
    encrypt      = true
  }
}
