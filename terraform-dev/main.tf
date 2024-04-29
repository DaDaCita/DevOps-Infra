data "aws_region" "current" {}

module "structure" {
  source                  = "./modules/structure"
        name_prefix             = "eks" // intentional so you can see the diff comment
  cidr                    = "10.0.0.0/16"
  azs                     = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}b", "${data.aws_region.current.name}c"]
  private_subnets         = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets          = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  cluster_name            = "eks_cluster_1"
  autoscaling_average_cpu = 50
}

module "eks_components" {
  source       = "./modules/eks_components"
  cluster_name = module.structure.cluster_object.cluster_id
}