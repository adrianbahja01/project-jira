output "cluster-name" {
  value = module.eks.cluster_name
}
output "cluster-endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster-certificate" {
  value = module.eks.cluster_certificate_authority_data
}

output "oidc_issuer" {
  value = module.eks.oidc_provider
}
