locals {
  cert_manager_issuers = {
    email                = "dns@nuon.co"
    server               = "https://acme-v02.api.letsencrypt.org/directory"
    public_issuer_name   = "public-issuer"
    internal_issuer_name = "internal-issuer"
  }
}

resource "kubectl_manifest" "internal_cluster_issuer" {
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      namespace = local.cert_manager.namespace
      name      = local.cert_manager_issuers.internal_issuer_name
    }
    spec = {
      acme = {
        email  = local.cert_manager_issuers.email
        server = local.cert_manager_issuers.server
        privateKeySecretRef = {
          name = local.cert_manager_issuers.internal_issuer_name
        }
        solvers = [
          {
            selector = {
              dnsZones = [
                aws_route53_zone.internal.name,
              ]
            }
            dns01 = {
              route53 = {
                region = var.region
                hostedZoneID : aws_route53_zone.internal.zone_id,
              }
            }
          }
        ]
      }
    }
  })

  depends_on = [
    helm_release.cert_manager
  ]
}

resource "kubectl_manifest" "public_cluster_issuer" {
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      namespace = local.cert_manager.namespace
      name      = local.cert_manager_issuers.public_issuer_name
    }
    spec = {
      acme = {
        email  = local.cert_manager_issuers.email
        server = local.cert_manager_issuers.server
        privateKeySecretRef = {
          name = local.cert_manager_issuers.public_issuer_name
        }
        solvers = [
          {
            selector = {
              dnsZones = [
                aws_route53_zone.public.name,
              ]
            }
            dns01 = {
              route53 = {
                region = var.region
                hostedZoneID : aws_route53_zone.public.zone_id
              }
            }
          }
        ]
      }
    }
  })
  depends_on = [
    helm_release.cert_manager
  ]
}
