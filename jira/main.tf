resource "kubernetes_namespace" "jira-ns" {
    metadata {
      name = "jira"
    }
}
resource "helm_release" "jira-software" {
  depends_on = [kubernetes_namespace.jira-ns]
  name       = var.helm_release_name
  repository = var.helm_repo_url
  chart      = var.helm_chart_name
  namespace  = var.jira_namespace

  set {
    name  = "postgresql.postgresqlPassword"
    value = local.postgress_pass
  }
  set {
    name  = "persistence.storageClass"
    value = "gp2"
  }
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
  
}
