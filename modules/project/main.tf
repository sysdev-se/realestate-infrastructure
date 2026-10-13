resource "google_project" "this" {
  name            = var.project_name
  project_id      = var.project_id
  folder_id       = var.folder_id
  billing_account = var.billing_account

  labels = var.labels

  auto_create_network = false
}

resource "google_project_service" "this" {
  for_each = toset(var.enabled_apis)

  project = google_project.this.project_id
  service = each.value

  disable_on_destroy = false
}
