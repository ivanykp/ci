variable "region" {}


variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
}


variable "sbn_cidr_block_private_a" {
    default = "10.0.0.0/19"
}


variable "sbn_cidr_block_private_b" {
    default = "10.0.32.0/19"
}


variable "sbn_cidr_block_private_c" {
    default = "10.0.64.0/19"
}


variable "sbn_cidr_block_public_a" {
    default = "10.0.96.0/19"
}


variable "sbn_cidr_block_public_b" {
    default = "10.0.128.0/19"
}


variable "sbn_cidr_block_public_c" {
    default = "10.0.160.0/19"
}