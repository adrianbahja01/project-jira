terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  required_version = ">= 1.4.0"
  backend "s3" {
    bucket         = "tf-remote-state-ab"
    key            = "project2jira.tfstate"
    region         = "us-east-1"
    profile        = "adrianpersonal"
    dynamodb_table = "tf-dynamodb-lock"
  }
}

provider "aws" {
  region  = var.region_name
  profile = var.profile_name
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.tf_remote_state_eks2.outputs.cluster-endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.tf_remote_state_eks2.outputs.cluster-certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["--region", "${var.region_name}", "--profile", "${var.profile_name}", "eks", "get-token", "--cluster-name", data.terraform_remote_state.tf_remote_state_eks2.outputs.cluster-name]
    command     = "aws"
  }
}

provider "helm" {
    kubernetes {
      host                   = data.terraform_remote_state.tf_remote_state_eks2.outputs.cluster-endpoint
      cluster_ca_certificate = base64decode(data.terraform_remote_state.tf_remote_state_eks2.outputs.cluster-certificate)
      exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        args        = ["--region", "${var.region_name}", "--profile", "${var.profile_name}", "eks", "get-token", "--cluster-name", data.terraform_remote_state.tf_remote_state_eks2.outputs.cluster-name]
        command     = "aws"
      }
    }
}
