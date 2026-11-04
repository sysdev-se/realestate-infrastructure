locals {
  labels = {
    system      = "realestate"
    environment = var.environment
    managed-by  = "terraform"
  }

  # Cloud Run's deterministic URL (https://<service>-<project number>.<region>.run.app),
  # known without reading the service. Used where reading it would create a cycle:
  # the api's CORS reads realestate-web's URLs, so the web can't read the api's.
  api_url = "https://realestate-api-${module.project.project_number}.${var.region}.run.app"
}

module "project" {
  source = "../../modules/project"

  project_id      = var.project_id
  project_name    = "realestate-${var.environment}"
  folder_id       = var.folder_id
  billing_account = var.billing_account
  labels          = local.labels
}

# Images for all realestate apps in this environment.
resource "google_artifact_registry_repository" "containers" {
  project       = module.project.project_id
  location      = var.region
  repository_id = "containers"
  description   = "Container images for realestate ${var.environment}"
  format        = "DOCKER"
  labels        = local.labels

  cleanup_policies {
    id     = "keep-recent"
    action = "KEEP"
    most_recent_versions {
      keep_count = 10
    }
  }

  cleanup_policies {
    id     = "delete-old"
    action = "DELETE"
    condition {
      older_than = "2592000s" # 30 days
    }
  }
}

module "api" {
  source = "../../modules/cloud-run-service"

  project_id     = module.project.project_id
  project_number = module.project.project_number
  region         = var.region
  name           = "realestate-api"
  labels         = local.labels

  # Smallest useful size: scales to zero and is billed only while serving requests.
  cpu           = "1"
  memory        = "512Mi"
  min_instances = 0
  max_instances = 2

  # Browsers may call the api from realestate-web, under either of its run.app URLs.
  env = {
    CORS_ALLOWED_ORIGINS = join(",", module.web.urls)
    IMAGE_BUCKET         = google_storage_bucket.images.name
  }

  # JWT signing keys and the seeded admin's password, see secrets.tf.
  secret_env = {
    for name, secret in google_secret_manager_secret.api : name => secret.secret_id
  }

  public                      = true
  all_users_ingress_tag_value = var.all_users_ingress_tag_value

  # A revision referencing a secret with no version fails to start.
  depends_on = [google_secret_manager_secret_version.api]
}

# realestate-api's GitHub workflow impersonates this to push images and deploy.
module "api_deployer" {
  source = "../../modules/github-deployer"

  project_id                   = module.project.project_id
  account_id                   = "deploy-realestate-api"
  github_repository            = "sysdev-se/realestate-api"
  wif_pool_name                = var.wif_pool_name
  artifact_registry_location   = google_artifact_registry_repository.containers.location
  artifact_registry_repository = google_artifact_registry_repository.containers.repository_id
  cloud_run_location           = var.region
  cloud_run_service            = module.api.name
  runtime_service_account_id   = module.api.runtime_service_account_id
}

module "web" {
  source = "../../modules/cloud-run-service"

  project_id     = module.project.project_id
  project_number = module.project.project_number
  region         = var.region
  name           = "realestate-web"
  labels         = local.labels

  # Smallest useful size: scales to zero and is billed only while serving requests.
  cpu           = "1"
  memory        = "512Mi"
  min_instances = 0
  max_instances = 2

  # Read by Nuxt at runtime as runtimeConfig.public.apiBase.
  env = {
    NUXT_PUBLIC_API_BASE = local.api_url
  }

  public                      = true
  all_users_ingress_tag_value = var.all_users_ingress_tag_value
}

# realestate-web's GitHub workflow impersonates this to push images and deploy.
module "web_deployer" {
  source = "../../modules/github-deployer"

  project_id                   = module.project.project_id
  account_id                   = "deploy-realestate-web"
  github_repository            = "sysdev-se/realestate-web"
  wif_pool_name                = var.wif_pool_name
  artifact_registry_location   = google_artifact_registry_repository.containers.location
  artifact_registry_repository = google_artifact_registry_repository.containers.repository_id
  cloud_run_location           = var.region
  cloud_run_service            = module.web.name
  runtime_service_account_id   = module.web.runtime_service_account_id
}
