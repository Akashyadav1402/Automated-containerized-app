provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  name     = "devops-vpc"
}

module "subnets" {
  source          = "./modules/subnets"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  azs             = ["ap-south-1a", "ap-south-1b"]
}

module "igw" {
  source = "./modules/igw"
  vpc_id = module.vpc.vpc_id
}

module "nat" {
  source           = "./modules/nat"
  public_subnet_id = module.subnets.public_subnet_ids[0]
}

module "routes" {
  source          = "./modules/routes"
  vpc_id          = module.vpc.vpc_id
  igw_id          = module.igw.igw_id
  nat_id          = module.nat.nat_id
  public_subnets  = module.subnets.public_subnet_ids
  private_subnets = module.subnets.private_subnet_ids
}

module "alb" {
  source             = "./modules/alb"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.subnets.public_subnet_ids
  project_name       = var.project_name
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = "${var.project_name}-repo"
}


module "ecs" {
  source             = "./modules/ecs"
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.subnets.private_subnet_ids
  alb_sg_id          = module.alb.alb_sg_id
  target_group_arn   = module.alb.target_group_arn
  ecr_image          = module.ecr.repository_url
}
