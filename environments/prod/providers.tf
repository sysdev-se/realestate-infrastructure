# Authenticates as tf-realestate: via WIF in GitHub Actions, or via
# `gcloud auth application-default login` (with impersonation) locally.
provider "google" {
  region = var.region
}
