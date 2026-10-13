# Service account a GitHub repo impersonates (via WIF) to push images and
# deploy one Cloud Run service. It can do nothing else.
resource "google_service_account" "this" {
  project      = var.project_id
  account_id   = var.account_id
  display_name = "GitHub deployer: ${var.github_repository}"
}

resource "google_service_account_iam_member" "wif" {
  service_account_id = google_service_account.this.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${var.wif_pool_name}/attribute.repository/${var.github_repository}"
}

resource "google_artifact_registry_repository_iam_member" "writer" {
  project    = var.project_id
  location   = var.artifact_registry_location
  repository = var.artifact_registry_repository
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.this.email}"
}

resource "google_cloud_run_v2_service_iam_member" "developer" {
  project  = var.project_id
  location = var.cloud_run_location
  name     = var.cloud_run_service
  role     = "roles/run.developer"
  member   = "serviceAccount:${google_service_account.this.email}"
}

# Deploying a revision that uses Direct VPC egress requires using the subnet.
resource "google_compute_subnetwork_iam_member" "network_user" {
  count = var.vpc_subnetwork != null ? 1 : 0

  project    = var.project_id
  subnetwork = var.vpc_subnetwork
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${google_service_account.this.email}"
}

# Deploying a revision that runs as the runtime SA requires actAs on it.
resource "google_service_account_iam_member" "act_as_runtime" {
  service_account_id = var.runtime_service_account_id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.this.email}"
}
