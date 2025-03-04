data "aws_availability_zones" "zones" {}

module "vpc" {
  source               = "Terraform-aws-modules/vpc/aws"
  name                 = "${var.cluster_name}-vpc"
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.zones.names
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_nat_gateway   = true
  enable_dns_hostnames = true
  
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/nlb"                    = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-nlb"           = "1"
  }
}