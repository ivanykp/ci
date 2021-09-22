output "vpc" {
    value = aws_vpc.vpc_template
}


output "dna_private" {
    value = aws_default_network_acl.dna_template_private
}


output "sgr_bastion" {
    value = aws_security_group.sgr_template_bastion
}


output "sbn_private_a" {
    value = aws_subnet.sbn_template_private_a
}


output "sbn_private_b" {
    value = aws_subnet.sbn_template_private_b
}


output "sbn_private_c" {
    value = aws_subnet.sbn_template_private_c
}


output "sbn_public_a" {
    value = aws_subnet.sbn_template_public_a
}


output "sbn_public_b" {
    value = aws_subnet.sbn_template_public_b
}


output "sbn_public_c" {
    value = aws_subnet.sbn_template_public_c
}