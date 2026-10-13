terraform {
  backend "gcs" {
    bucket = "sysdev-tfstate-realestate"
    prefix = "prod"
  }
}
