# Scrapers: one Cloud Run job per scraped website, each from its own repo, run daily by
# Cloud Scheduler. They post listings to realestate-api's /api/v1/scraper/** with a Google ID
# token for their runtime SA; the api accepts only the SAs in SCRAPER_ACCOUNTS (main.tf),
# which come from local.scrapers. The key is the listing source the api records.
#
# To add a scraper: add an entry below, create its repo and give it GCP_WIF_PROVIDER and
# GCP_SERVICE_ACCOUNT (output scraper_deployer_service_accounts).
locals {
  scrapers = {
    fazwaz = {
      github_repository = "sysdev-se/realestate-scraper-fazwaz"
      # 03:00 Vietnam time.
      schedule = "0 3 * * *"
      env = {
        # fazwaz search with its filters applied (here: Da Nang rentals from 20M VND/month).
        # robots.txt disallows order_by, so leave it out.
        START_URL = "https://www.fazwaz.vn/property-for-rent/vietnam/da-nang?mapEnable=0&monthly_price=20000000,null"
        MAX_PAGES = "2"
      }
    }
  }
}

module "scraper" {
  source   = "../../modules/cloud-run-job"
  for_each = local.scrapers

  project_id = module.project.project_id
  region     = var.region
  name       = "realestate-scraper-${each.key}"
  labels     = local.labels

  # One request at a time to the website, so a small task is plenty.
  cpu      = "1"
  memory   = "512Mi"
  timeout  = "1800s"
  schedule = each.value.schedule

  env = merge(each.value.env, {
    # Also the audience of the ID token the scraper sends.
    API_BASE_URL = local.api_url
  })
}

# The scraper repo's GitHub workflow impersonates this to push images and update the job.
module "scraper_deployer" {
  source   = "../../modules/github-deployer"
  for_each = local.scrapers

  project_id                   = module.project.project_id
  account_id                   = "deploy-scraper-${each.key}"
  github_repository            = each.value.github_repository
  wif_pool_name                = var.wif_pool_name
  artifact_registry_location   = google_artifact_registry_repository.containers.location
  artifact_registry_repository = google_artifact_registry_repository.containers.repository_id
  cloud_run_location           = var.region
  cloud_run_job                = module.scraper[each.key].name
  runtime_service_account_id   = module.scraper[each.key].runtime_service_account_id
}
