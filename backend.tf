terraform {
  backend "s3" {
    bucket         = "interview-project-bucket-009909"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
