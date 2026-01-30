module "vpc" {
  source = "../../modules/vpc"

  environment     = "prod"
  vpc_cidr        = "10.1.0.0/16"
  public_subnets  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets = ["10.1.101.0/24", "10.1.102.0/24"]
  azs             = ["eu-west-1a", "eu-west-1b"]
}



module "alb" {
  source = "../../modules/alb"

  environment       = "prod"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}


module "ec2" {
  source = "../../modules/ec2"

  environment           = "prod"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
}



module "rds" {
  source = "../../modules/rds"

  environment           = "prod"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ec2_security_group_id = module.ec2.ec2_security_group_id
}

