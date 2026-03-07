module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "21.15.1"

    name = "myapp-eks-cluster"
    kubernetes_version  = "1.30"

    // to access cluster from external client
    endpoint_public_access = true

    // subnet where we want worker nodes 
    // we want all workload in private subnet for security reason
    subnet_ids = module.myapp-vpc.private_subnets

    vpc_id = module.myapp-vpc.vpc_id

    eks_managed_node_groups = {
        dev = {
            instance_types = ["t3.small"]

            min_size     = 1
            max_size     = 3
            desired_size = 3
        }
    }

    tags = {
        // for our reference only
        environment = "development"
        app = "myapp"
    }
}

 