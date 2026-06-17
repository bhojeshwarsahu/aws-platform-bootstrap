terraform {
  backend "s3" {
    bucket       = "skilli-prod-627807502978-tf-state"
    key          = "bootstrap/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}