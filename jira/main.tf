resource "kubernetes_namespace" "jira-ns" {
    metadata {
      name = "jira"
    }
}
resource "helm_release" "jira-software" {
  depends_on = [kubernetes_namespace.jira-ns, helm_release.alb_ingress, helm_release.external-dns]
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
    name = "fullnameOverride"
    value = var.helm_release_name
  }

  # set {
  #   name  = "service.type"
  #   value = "LoadBalancer"
  # }
  
}

resource "kubernetes_ingress_v1" "jira-ingress" {
  depends_on = [ helm_release.jira-software ]
  wait_for_load_balancer = true
  metadata {
    name      = "jira-ingress"
    namespace = var.jira_namespace
    annotations = {
      "alb.ingress.kubernetes.io/certificate-arn" : module.acm.acm_certificate_arn
      "external-dns.alpha.kubernetes.io/alias" : "true"
      "alb.ingress.kubernetes.io/healthcheck-path" : "/"
      "alb.ingress.kubernetes.io/listen-ports" : "[{\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/scheme" : "internet-facing"
      "alb.ingress.kubernetes.io/ssl-policy" : "ELBSecurityPolicy-TLS-1-2-2017-01"
      "alb.ingress.kubernetes.io/success-codes" : "200,404,401"
      "alb.ingress.kubernetes.io/target-type" : "ip"
      "kubernetes.io/ingress.class" : "alb"
      "alb.ingress.kubernetes.io/inbound-cidrs" : "0.0.0.0/0"
    }
  }

  spec {
    ingress_class_name = "alb"
    rule {
      host = "${var.jira_hostname}.${var.domain_name}"
      http {
        path {
          backend {
            service {
              name = var.helm_release_name
              port {
                number = 80
              }
            }
          }
          path      = "/"
          path_type = "Prefix"
        }
      }
    }
  }
}
