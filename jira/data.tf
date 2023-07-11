data "aws_secretsmanager_secret" "db_secret" {
  name = "db_secret"
}

data "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}

locals {
  postgress_pass = jsondecode(data.aws_secretsmanager_secret_version.db_secret_version.secret_string)["db_pass"]
}

data "terraform_remote_state" "tf_remote_state_eks2" {
  backend = "s3"

  config = {
    bucket  = "tf-remote-state-ab"
    key     = "project2eks.tfstate"
    region  = "us-east-1"
    profile = "adrianpersonal"
  }
}

data "terraform_remote_state" "tf_remote_state_vpc2" {
  backend = "s3"

  config = {
    bucket  = "tf-remote-state-ab"
    key     = "project2vpc.tfstate"
    region  = "us-east-1"
    profile = "adrianpersonal"
  }
}

data "aws_route53_zone" "dns-main" {
  name = var.domain_name
}
