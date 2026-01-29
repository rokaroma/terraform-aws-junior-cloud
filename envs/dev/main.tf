module "vpc" {
  source = "../../modules/vpc"

  environment     = "dev"
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  azs             = ["eu-west-1a", "eu-west-1b"]
}


module "alb" {
  source = "../../modules/alb"

  environment       = "dev"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}


module "ec2" {
  source = "../../modules/ec2"

  environment           = "dev"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
}


module "rds" {
  source = "../../modules/rds"

  environment             = "dev"
  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  ec2_security_group_id   = module.ec2.ec2_security_group_id
}
