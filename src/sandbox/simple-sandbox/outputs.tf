# lambda-specific outputs

output "lambda_function_arn" {
  description = "The ARN of the deployed Lambda function."
  value       = aws_lambda_function.my_lambda_function.arn
}

output "api_gateway_invoke_url" {
  description = "The invoke URL for the API Gateway endpoint."
  value       = aws_api_gateway_deployment.lambda_api_deployment.invoke_url
}


# nuon-specific outputs
output "runner" {
  value = {
    odr_iam_role_arn     = module.odr_iam_role.iam_role_arn
    install_iam_role_arn = module.runner_install_iam_role.iam_role_arn
  }
  description = "A map of runner attributes: install_iam_role_arn"
}

output "vpc" {
  // NOTE: these are declared here -
  // https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest?tab=outputs
  value = {
    name = module.vpc.name
    id   = module.vpc.vpc_id
    cidr = module.vpc.vpc_cidr_block
    azs  = module.vpc.azs

    private_subnet_cidr_blocks = module.vpc.private_subnets_cidr_blocks
    private_subnet_ids         = module.vpc.private_subnets

    public_subnet_cidr_blocks = module.vpc.public_subnets_cidr_blocks
    public_subnet_ids         = module.vpc.public_subnets

    default_security_group_id = aws_security_group.runner.id
    # default_security_group_arn = aws_security_group.runner.arn
    db_subnet_group_name = module.vpc.database_subnet_group_name
    db_subnet_group_id   = module.vpc.database_subnet_group
  }
  description = "A map of vpc attributes: name, id, cidr, azs, private_subnet_cidr_blocks, private_subnet_ids, public_subnet_cidr_blocks, public_subnet_ids, default_security_group_id db_subnet_group_name, db_subnet_group_id."
}

output "account" {
  value = {
    id     = data.aws_caller_identity.current.account_id
    region = var.region
  }
  description = "A map of AWS account attributes: id, region"
}

output "ecr" {
  value = {
    repository_url  = module.ecr.repository_url
    repository_arn  = module.ecr.repository_arn
    repository_name = local.prefix
    registry_id     = module.ecr.repository_registry_id
    registry_url    = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
  }
  description = "A map of ECR attributes: repository_url, repository_arn, repository_name, registry_id, registry_url."
}

output "public_domain" {
  value = {
    nameservers = var.enable_public_route53_zone ? aws_route53_zone.public[0].name_servers : []
    name        = var.enable_public_route53_zone ? aws_route53_zone.public[0].name : ""
    zone_id     = var.enable_public_route53_zone ? aws_route53_zone.public[0].id : ""
  }
  description = "A map of public Route53 zone attributes: nameservers, name, zone_id."
}

output "internal_domain" {
  value = {
    nameservers = aws_route53_zone.internal.name_servers
    name        = aws_route53_zone.internal.name
    zone_id     = aws_route53_zone.internal.id
  }
  description = "A map of internal Route53 zone attributes: nameservers, name, zone_id."
}
