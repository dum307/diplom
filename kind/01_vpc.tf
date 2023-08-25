module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dum307-vpc"
  cidr = var.vpc_cidr_block

  azs             = var.azs
  #private_subnets = var.private_subnet_cidr
  public_subnets  = var.public_subnet_cidr

  #enable_nat_gateway = true
  #single_nat_gateway = true

}
