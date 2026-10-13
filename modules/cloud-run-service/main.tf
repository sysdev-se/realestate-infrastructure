# Identity the service runs as. Grants it needs are passed in via
# project_roles and secret_env, and applied before the service is created.
resource "google_service_account" "runtime" {
  project      = var.project_id
  account_id   = var.name
  display_name = "Cloud Run runtime: ${var.name}"
}

resource "google_project_iam_member" "runtime" {
  for_each = toset(var.project_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.runtime.email}"
}

resource "google_secret_manager_secret_iam_member" "runtime" {
  for_each = var.secret_env

  project   = var.project_id
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.runtime.email}"
}

resource "google_cloud_run_v2_service" "this" {
  project  = var.project_id
  name     = var.name
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"
  labels   = var.labels

  deletion_protection = false

  template {
    service_account = google_service_account.runtime.email

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    containers {
      # Only the first deploy uses this image; the app repo deploys new ones.
      image = var.initial_image

      ports {
        container_port = var.container_port
      }

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
        cpu_idle = true
      }

      dynamic "env" {
        for_each = var.env
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = var.secret_env
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = env.value
              version = "latest"
            }
          }
        }
      }

    }

    # Direct VPC egress: only traffic to private ranges goes through the VPC.
    dynamic "vpc_access" {
      for_each = var.vpc_subnetwork != null ? [1] : []
      content {
        egress = "PRIVATE_RANGES_ONLY"
        network_interfaces {
          subnetwork = var.vpc_subnetwork
        }
      }
    }
  }

  lifecycle {
    # The image is owned by the app repo's deploy pipeline, not Terraform.
    ignore_changes = [
      client,
      client_version,
      template[0].containers[0].image,
    ]
  }

  depends_on = [
    google_project_iam_member.runtime,
    google_secret_manager_secret_iam_member.runtime,
  ]
}

# The org's domain restricted sharing policy rejects allUsers unless the
# resource carries allUsersIngress=True (see root-infrastructure drs.tf).
resource "google_tags_location_tag_binding" "all_users_ingress" {
  count = var.public ? 1 : 0

  parent    = "//run.googleapis.com/projects/${var.project_number}/locations/${var.region}/services/${google_cloud_run_v2_service.this.name}"
  tag_value = var.all_users_ingress_tag_value
  location  = var.region
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  count = var.public ? 1 : 0

  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.this.name
  role     = "roles/run.invoker"
  member   = "allUsers"

  depends_on = [google_tags_location_tag_binding.all_users_ingress]
}
