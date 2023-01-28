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

  helm_config   = {
    values = [templatefile("${path.module}/values.yaml", {
      certificate_arn = var.certificate_arn
    })]
   }
  addon_context = local.addon_context
}