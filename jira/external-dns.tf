resource "helm_release" "external-dns" {
  name       = "external-dns"
  namespace  = "kube-system"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  #  version    = "6.5.6"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_dns.arn
  }

  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }

  set {
    name  = "zoneType"
    value = "public"
  }

  set {
    name  = "policy"
    value = "sync"
  }

  set {
    name  = "domainFilters[0]"
    value = var.domain_name
  }

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "txtOwnerId" # TXT record identifier
    value = "external-dns"
  }
}

resource "aws_iam_role" "external_dns" {
  name = "external-dns-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.account_id}:oidc-provider/${data.terraform_remote_state.tf_remote_state_eks2.outputs.oidc_issuer}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${data.terraform_remote_state.tf_remote_state_eks2.outputs.oidc_issuer}:aud": "sts.amazonaws.com",
          "${data.terraform_remote_state.tf_remote_state_eks2.outputs.oidc_issuer}:sub": "system:serviceaccount:kube-system:external-dns"
        }
      }
    }
  ]
}
EOF
  tags = {
    Terraform = "true"
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

resource "aws_iam_policy" "external_dns" {
  name        = "external-dns-policy"
  description = "Policy using OIDC to give the EKS external dns ServiceAccount permissions to update Route53"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
     "Effect": "Allow",
     "Action": [
       "route53:ChangeResourceRecordSets"
     ],
     "Resource": [
       "arn:aws:route53:::hostedzone/*"
     ]
   },
   {
     "Effect": "Allow",
     "Action": [
       "route53:ListHostedZones",
       "route53:ListResourceRecordSets"
     ],
     "Resource": [
       "*"
     ]
   }
  ]
}
EOF
}
