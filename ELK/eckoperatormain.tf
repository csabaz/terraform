resource "helm_release" "eck-operator" {
  name       = "eck-operator"
  repository = "https://helm.elastic.co"
  chart      = "eck-operator"
  namespace         = "elastic-system"
  create_namespace  = true
  force_update = true
  dependency_update = true #helm repo update command
}
