module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = ">= 2.1.0"

  create                                    = true
  create_repository                         = true
  create_repository_policy                  = true
  attach_repository_policy                  = false
  create_lifecycle_policy                   = false
  create_registry_replication_configuration = false

  repository_name                 = local.prefix
  repository_image_tag_mutability = "MUTABLE"
  repository_encryption_type      = "KMS"
  repository_image_scan_on_push   = false
  repository_force_delete         = true
}
