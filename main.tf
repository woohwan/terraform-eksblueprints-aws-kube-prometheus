# create S3 bucket for thanos store
resource "aws_s3_bucket" "thanos" {
  bucket = "${var.addon_context.eks_cluster_id}-thanos"
  tags = {
    "Blueprints" = var.addon_context.eks_cluster_id
  }
}

resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = local.namespace
  }
}

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

# secret for Thnanos sidecar storage
resource "kubernetes_secret_v1" "prometheus_object_store_config" {
  metadata {
    name = "thanos-sidecar-objstore-secret"
    namespace = kubernetes_namespace.prometheus.metadata[0].name
  }

  data = {
    "thanos.yaml" = yamlencode({
      type = "s3"
      config = {
        bucket = aws_s3_bucket.thanos.bucket
        endpoint = replace(aws_s3_bucket.thanos.bucket_regional_domain_name, "${aws_s3_bucket.thanos.bucket}.","")
      }
    })
  }
}

