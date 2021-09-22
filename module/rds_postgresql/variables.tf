variable "instance_class" {
    default = "db.t3.medium"
}


variable "vpc" {}


variable "dna_private" {}


variable "sgr_bastion" {}
variable "ec2_bastion" {}


variable "sbn_private_a" {}
variable "sbn_private_b" {}
variable "sbn_private_c" {}

variable "sbn_public_a" {}
variable "sbn_public_b" {}
variable "sbn_public_c" {}


variable "rcl_backup_window" {
    default = "19:00-20:30"
}


variable "rcl_maintenance_window" {
    default = "sun:20:30-sun:22:00"
}


variable "rcl_username" {
    default = "postgres"
}


variable "rcl_password" {}


variable "kky" {}


variable "kpr_private_key" {}