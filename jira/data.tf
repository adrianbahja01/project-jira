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

data "aws_route53_zone" "dns-main" {
  name = var.domain_name
}

# data "aws_resourcegroupstaggingapi_resources" "elb-api" {
#   resource_type_filters = ["elasticloadbalancing:loadbalancer"]
#   depends_on = [ helm_release.jira-software ]

#   tag_filter {
#     key    = "kubernetes.io/service-name"
#     values = ["${var.jira_namespace}/jira-software"]
#   }
# }

# locals {
#   elb_with_tags = {
#     elb_name = element(split("/", data.aws_resourcegroupstaggingapi_resources.elb-api.resource_tag_mapping_list[0].resource_arn), 1)
#     elb_tags = data.aws_resourcegroupstaggingapi_resources.elb-api.resource_tag_mapping_list[0].tags
#   }
# }

# data "aws_elb" "elb" {
#   name = local.elb_with_tags.elb_name
# }
