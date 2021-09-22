provider "aws" {
    region = var.region
}


module "kms_test_bastion" {
    source = "./module/kms"
}


module "kms_test_postgresql" {
    source = "./module/kms"
}


module "keypair_test" {
    source = "./module/keypair"
    
    kpr_public_key = var.kpr_public_key
}


module "vpc_test" {
    source = "./module/vpc"
    
    region = var.region
}


module "ec2_bastion_test_a" {
    source = "./module/ec2_bastion"
    
    sbn = module.vpc_test.sbn_public_a
    sgr = module.vpc_test.sgr_bastion
    
    kky             = module.kms_test_bastion.kky
    kpr             = module.keypair_test.kpr
    kpr_private_key = var.kpr_private_key
}


module "ec2_bastion_test_b" {
    source = "./module/ec2_bastion"
    
    sbn = module.vpc_test.sbn_public_b
    sgr = module.vpc_test.sgr_bastion
    
    kky             = module.kms_test_bastion.kky
    kpr             = module.keypair_test.kpr
    kpr_private_key = var.kpr_private_key
}


module "lb_bastion_test" {
    source = "./module/lb_bastion"

    vpc          = module.vpc_test.vpc
    sbn_public_a = module.vpc_test.sbn_public_a
    sbn_public_b = module.vpc_test.sbn_public_b
    sbn_public_c = module.vpc_test.sbn_public_c
    
    tga_target_a = module.ec2_bastion_test_a.ec2
    tga_target_b = module.ec2_bastion_test_b.ec2
}


module "rds_postgresql_test" {
    source = "./module/rds_postgresql"
    
    vpc = module.vpc_test.vpc
    
    dna_private = module.vpc_test.dna_private
    
    sgr_bastion = module.vpc_test.sgr_bastion
    ec2_bastion = module.ec2_bastion_test_a.eip.public_ip
    
    sbn_private_a = module.vpc_test.sbn_private_a
    sbn_private_b = module.vpc_test.sbn_private_b
    sbn_private_c = module.vpc_test.sbn_private_c
    
    sbn_public_a = module.vpc_test.sbn_public_a
    sbn_public_b = module.vpc_test.sbn_public_b
    sbn_public_c = module.vpc_test.sbn_public_c
    
    kky             = module.kms_test_postgresql.kky
    kpr_private_key = var.kpr_private_key
    rcl_password    = var.rcl_password
}