module "network" {
  source             = "../../modules/network"
  project            = var.project
  environment        = var.environment
  single_nat_gateway = var.single_nat_gateway

}

# The output is a map keyed by AZ, and the input wants one string. values() returns a list ordered by key, and the [0] index.
locals {
  app_subnet_id = values(module.network.private_subnets_ids)[0]
}

module "compute" {
  source            = "../../modules/compute"
  project           = var.project
  environment       = var.environment
  vpc_id            = module.network.vpc_id
  private_subnet_id = local.app_subnet_id
  instance_type     = var.instance_type

}

module "storage" {
  source                           = "../../modules/storage"
  project                          = var.project
  environment                      = var.environment
  vpc_id                           = module.network.vpc_id
  enable_force_destroy             = var.force_destroy
  log_retention_days               = var.log_retention_days
  noncurrent_object_retention_days = var.noncurrent_object_retention_days
}