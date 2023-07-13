data "terraform_remote_state" "tf_remote_state_vpc2" {
  backend = "s3"

  config = {
    bucket  = "tf-remote-state-ab"
    key     = "project2vpc.tfstate"
    region  = "us-east-1"
    profile = "adrianpersonal"
  }
}
