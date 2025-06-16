# tag subnet for use by this cluster
# the VPC tags these subnets by default: we need to add these tags only if the cluster_name is not the nuon install id
resource "aws_ec2_tag" "private_subnets_cluster_tags" {
  for_each    = toset(var.private_subnet_ids)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${var.eks_cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "public_subnets_cluster_tags" {
  for_each    = toset(var.public_subnet_ids)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${var.eks_cluster_name}"
  value       = "shared"
}
