provider "google" {
  version = "~>v2.13.0"

  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
}
