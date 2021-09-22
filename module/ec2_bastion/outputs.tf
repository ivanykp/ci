output "ec2" {
    value = aws_instance.ins_template_bastion
}


output "eip" {
    value = aws_eip.eip_template_bastion
}