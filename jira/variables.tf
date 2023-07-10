variable "profile_name" {
  description = "The AWS profile name which is configured locally"
}

variable "project_name" {
  description = "The project name which can be used broadly when creating AWS resources"
}

variable "region_name" {
  description = "The region name where to deploy AWS resources"
}

variable "helm_release_name" {
  description = "The helm chart release name"
}

variable "helm_chart_name" {
  description = "The helm chart name"
}

variable "helm_repo_url" {
  description = "The helm chart repo URL"
}

variable "jira_namespace" {
     description = "Namespace name used for Jira s"
}

variable "jira_hostname" {
  description = "The DNS record name which will be used for Jira"
}

variable "domain_name" {
  description = "The DNS record name which will be used by LB"
}
