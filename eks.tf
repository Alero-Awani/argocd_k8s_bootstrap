module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.31"
  subnet_ids      = module.vpc.private_subnets
  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "test"
  }

  vpc_id = module.vpc.vpc_id

  self_managed_node_groups = {

    utilities_group = {
      ami_type      = "AL2_x86_64"
      instance_type = "t2.medium"

      min_size = 1
      max_size = 1
      desired_size = 1
    },
    applications_group = {
      ami_type      = "AL2_x86_64"
      instance_type = "t2.medium"

      min_size = 1
      max_size = 1
      desired_size = 1
    }
  }
}



resource "null_resource" "kubectl" {
    provisioner "local-exec" {
        command = "aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name}"
    }
    depends_on = [module.eks]
}