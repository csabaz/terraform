terraform {
  required_providers {  
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}

resource "kubernetes_namespace" "elkcloud_namespace" {
  metadata {
    annotations = {
      name = "logging"
    }
    name = "logging"
  }
}

data "kubectl_filename_list" "manifests_deployment_op" {
    pattern = "./deployment/*.yaml"
}

resource "kubectl_manifest" "operator_deploy" {
    count = length(data.kubectl_filename_list.manifests_deployment_op.matches)
    yaml_body = file(element(data.kubectl_filename_list.manifests_deployment_op.matches, count.index))
    override_namespace = "logging"
    depends_on = [
    helm_release.eck-operator
  ]
}
