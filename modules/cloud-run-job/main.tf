# Identity the job runs as. It is also the identity Cloud Scheduler uses to start the
# job, so it may run this job (and nothing else).
resource "google_service_account" "runtime" {
  project      = var.project_id
  account_id   = var.name
  display_name = "Cloud Run job runtime: ${var.name}"
}

resource "google_cloud_run_v2_job" "this" {
  project  = var.project_id
  name     = var.name
  location = var.region
  labels   = var.labels

  deletion_protection = false

  template {
    task_count = 1

    template {
      service_account = google_service_account.runtime.email
      timeout         = var.timeout
      max_retries     = var.max_retries

      containers {
        # Only the first deploy uses this image; the app repo deploys new ones.
        image = var.initial_image

        resources {
          limits = {
            cpu    = var.cpu
            memory = var.memory
          }
        }

        dynamic "env" {
          for_each = var.env
          content {
            name  = env.key
            value = env.value
          }
        }
      }
    }
  }

  lifecycle {
    # The image is owned by the app repo's deploy pipeline, not Terraform.
    ignore_changes = [
      client,
      client_version,
      template[0].template[0].containers[0].image,
    ]
  }
}

resource "google_cloud_run_v2_job_iam_member" "scheduler" {
  count = var.schedule != null ? 1 : 0

  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_job.this.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.runtime.email}"
}

# Starts an execution through the Cloud Run Admin API (jobs.run).
resource "google_cloud_scheduler_job" "this" {
  count = var.schedule != null ? 1 : 0

  project   = var.project_id
  region    = var.region
  name      = var.name
  schedule  = var.schedule
  time_zone = var.time_zone

  # No retry_config: the default (retry_count 0) means a failed start is not retried; the next
  # scheduled run picks up what it missed. Setting it explicitly only causes a permanent diff,
  # since the API doesn't return an all-default retry_config.

  http_target {
    http_method = "POST"
    uri         = "https://run.googleapis.com/v2/${google_cloud_run_v2_job.this.id}:run"

    oauth_token {
      service_account_email = google_service_account.runtime.email
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
    }
  }

  depends_on = [google_cloud_run_v2_job_iam_member.scheduler]
}
