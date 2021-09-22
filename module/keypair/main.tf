resource "aws_key_pair" "kpr_template" {
    key_name   = var.kpr_key_name
    public_key = var.kpr_public_key
}