locals {
  master_utils_values = <<-EOT
  apiVersion: argoproj.io/v1alpha1
  kind: Application
  metadata:
    name: master-utilities
    finalizers:
      - resources-finalizer.argocd.argoproj.io
  spec:
    project: default
    source:
      repoURL: https://github.com/Alero-Awani/argocd_k8s_bootstrap.git
      targetRevision: HEAD
      path: applications/master-utilities
      helm:
        values: |
          externalDNS:
            iamRole: ${aws_iam_role.external_dns.arn}
            domain: ${var.domain}
            txtOwnerID: ${var.zone_id}

    destination:
      namespace: argocd
      server: https://kubernetes.default.svc

    syncPolicy: 
      automated:
        prune: true
        selfHeal: true

  EOT

  values_dev = <<-EOT
  spec:
    destination:
      server: https://kubernetes.default.svc

  externalDNS:
    iamRole: ${aws_iam_role.external_dns.arn}
    domain: ${var.domain}
    txtOwnerID: ${var.zone_id}
  EOT
}

resource "local_file" "master_utils_values" {
  filename = "./k8s-bootstrap/base/master-utilities.yaml"
  content  = local.master_utils_values
}

resource "local_file" "master_utils_values_yaml" {
  filename = "./applications/master-utilities/values.yaml"
  content  = local.values_dev
}

data "kustomization_build" "argocd_namespace" {
  path = "./k8s-bootstrap/namespace"
}

resource "kustomization_resource" "argocd_namespace" {
  for_each = data.kustomization_build.argocd_namespace.ids
  manifest = data.kustomization_build.argocd_namespace.manifests[each.value]
  depends_on = [time_sleep.wait_30_seconds]

}
resource "time_sleep" "wait_60_seconds" {
  depends_on      = [kustomization_resource.argocd_namespace]
  create_duration = "60s"
}

data "kustomization_build" "argocd" {
  path = "./k8s-bootstrap/bootstrap"
}

resource "kustomization_resource" "argocd" {
  for_each = data.kustomization_build.argocd.ids
  manifest = data.kustomization_build.argocd.manifests[each.value]
  depends_on = [
    time_sleep.wait_60_seconds,
    local_file.master_utils_values,
    local_file.master_utils_values_yaml,
  ]
  lifecycle {
    ignore_changes = [manifest]
  }
}