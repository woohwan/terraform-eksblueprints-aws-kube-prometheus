
module "helm_addon" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons/helm-addon?ref=v4.21.0"
  
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

# create IAM Policy for thanos sidecar
resource "aws_iam_policy" "thanos_sidecar" {
  name_prefix = "thanos_sidecar-"
  description = "policy for thanos sidecar in project osung-mart"
  policy = data.aws_iam_policy_document.thanos_sidecar.json

  tags = var.addon_context.tags
}


