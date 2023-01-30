locals {

  s3_bucket_arn     = var.s3_bucket_arn

  name              = try(var.helm_config.name, "kube-prometheus-stack")
  namespace         = try(var.helm_config.namespace, local.name)
  service_account   = try(var.helm_config.service_account, "${local.name}-sa")

  argocd_gitops_config = {
    enable = true
  }

  # https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/Chart.yaml
  default_helm_config = {
    name       = local.name
    chart      = local.name
    repository = "https://prometheus-community.github.io/helm-charts"
    version    = "44.3.0"
    namespace  = local.namespace
    description = "kube-prometheus-stack helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )
  

  irsa_config = {
    kubernetes_namespace                = local.helm_config["namespace"]
    kubernetes_service_account          = local.service_account
    create_kubernetes_namespace         = false
    create_kubernetes_service_account   = true
    create_service_account_secret_token = try(local.helm_config["create_service_account_secret_token"], false)
    irsa_iam_policies                   = [aws_iam_policy.thanos_sidecar.arn]
    eks_cluster_id                      = var.addon_context.eks_cluster_id
    eks_oidc_provider_arn               = var.addon_context.eks_oidc_provider_arn
    tags                                = var.addon_context.tags
  }

}