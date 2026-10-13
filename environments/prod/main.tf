locals {
  labels = {
    system      = "realestate"
    environment = var.environment
    managed-by  = "terraform"
  }
}

module "project" {
  source = "../../modules/project"

  project_id      = var.project_id
  project_name    = "realestate-${var.environment}"
  folder_id       = var.folder_id
  billing_account = var.billing_account
  labels          = local.labels
}
