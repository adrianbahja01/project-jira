resource "aws_iam_policy" "alb-ingress-controller-iam-policy" {
  name        = "${data.terraform_remote_state.tf_remote_state_eks2.outputs.cluster-name}-alb-iam-policy"
  policy      = data.aws_iam_policy_document.ingress-policy.json
  description = "Policy for alb-ingress service"
}

resource "aws_iam_role" "alb_ingress" {
  name = "${data.terraform_remote_state.tf_remote_state_eks2.outputs.cluster-name}-alb-ingress"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringEquals = {
              "${data.terraform_remote_state.tf_remote_state_eks2.outputs.oidc_issuer}:aud" = "sts.amazonaws.com",
              "${data.terraform_remote_state.tf_remote_state_eks2.outputs.oidc_issuer}:sub" = "system:serviceaccount:kube-system:${var.ingressC_service_account_name}"
            }
          }
          Effect = "Allow",
          Principal = {
            Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${data.terraform_remote_state.tf_remote_state_eks2.outputs.oidc_issuer}"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "alb_ingress" {
  role       = aws_iam_role.alb_ingress.name
  policy_arn = aws_iam_policy.alb-ingress-controller-iam-policy.arn
}

resource "helm_release" "alb_ingress" {
  depends_on = [module.acm]
  name       = "aws-alb-ingress-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "region"
    value = var.region_name
  }

  set {
    name  = "clusterName"
    value = data.terraform_remote_state.tf_remote_state_eks2.outputs.cluster-name
  }

  set {
    name  = "vpcId"
    value = data.terraform_remote_state.tf_remote_state_vpc2.outputs.vpc_id
  }
  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = var.ingressC_service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_ingress.arn
  }

  set {
    name  = "awsLoadBalancerController.service.beta.kubernetes.io/aws-load-balancer-ssl-cert"
    value = module.acm.acm_certificate_arn
  }

  set {
    name  = "awsLoadBalancerController.service.beta.kubernetes.io/aws-load-balancer-ssl-ports"
    value = "443"
  }
}
