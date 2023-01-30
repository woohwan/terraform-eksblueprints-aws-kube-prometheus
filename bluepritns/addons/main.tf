provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = local.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = local.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

module "prometheus-stack" {
  source =  "../.."

  addon_context     = local.addon_context
  s3_bucket_arn     = aws_s3_bucket.thanos.arn

  helm_config   = {
    service_account   = local.service_account_name
    namespace         = kubernetes_namespace.prometheus.metadata[0].name
    values = [templatefile("${path.module}/values.yaml", {
      certificate_arn                       = var.certificate_arn
      thanos_sidecar_objconfig_secret_name  = kubernetes_secret_v1.prometheus_object_store_config.metadata[0].name
      service_account   = local.service_account_name
    })]
   }
  
  depends_on = [
    kubernetes_namespace.prometheus
  ]
}

resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = local.namespace
  }
}

# create S3 bucket for thanos store
resource "aws_s3_bucket" "thanos" {
  bucket = "${local.addon_context.eks_cluster_id}-thanos"
  tags = {
    "Blueprints" = local.addon_context.eks_cluster_id
  }
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