resource "aws_vpc" "vpc_template" {
	cidr_block = var.vpc_cidr_block
}


# *** INTERNET GATEWAY ***

resource "aws_internet_gateway" "igt_template" {
    vpc_id = aws_vpc.vpc_template.id
}


# *** PRIVATE ROUTE TABLE ***

resource "aws_default_route_table" "drt_template_private" {
	default_route_table_id = aws_vpc.vpc_template.default_route_table_id
}


resource "aws_route_table_association" "rta_template_private_a" {
	route_table_id = aws_default_route_table.drt_template_private.id
	subnet_id      = aws_subnet.sbn_template_private_a.id
}


resource "aws_route_table_association" "rta_template_private_b" {
	route_table_id = aws_default_route_table.drt_template_private.id
    subnet_id      = aws_subnet.sbn_template_private_b.id
}


resource "aws_route_table_association" "rta_template_private_c" {
    route_table_id = aws_default_route_table.drt_template_private.id
    subnet_id      = aws_subnet.sbn_template_private_c.id
}


# *** PUBLIC ROUTE TABLE ***

resource "aws_route_table" "rtb_template_public" {
	vpc_id = aws_vpc.vpc_template.id
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.igt_template.id
	}
}


resource "aws_route_table_association" "rta_template_public_a" {
    route_table_id = aws_route_table.rtb_template_public.id
    subnet_id      = aws_subnet.sbn_template_public_a.id
}


resource "aws_route_table_association" "rta_template_public_b" {
    route_table_id = aws_route_table.rtb_template_public.id
    subnet_id      = aws_subnet.sbn_template_public_b.id
}


resource "aws_route_table_association" "rta_template_public_c" {
    route_table_id = aws_route_table.rtb_template_public.id
    subnet_id      = aws_subnet.sbn_template_public_c.id
}


# *** PRIVATE ACL ***

resource "aws_default_network_acl" "dna_template_private" {
	default_network_acl_id = aws_vpc.vpc_template.default_network_acl_id
    subnet_ids             = [
        aws_subnet.sbn_template_private_a.id,
        aws_subnet.sbn_template_private_b.id,
        aws_subnet.sbn_template_private_c.id
    ]
    
    lifecycle {
        ignore_changes = [
            egress,
            ingress
        ]
    }
}


# *** PUBLIC ACL ***

resource "aws_network_acl" "nac_template_public" {
    vpc_id     = aws_vpc.vpc_template.id
    subnet_ids = [
        aws_subnet.sbn_template_public_a.id,
        aws_subnet.sbn_template_public_b.id,
        aws_subnet.sbn_template_public_c.id
    ]
}


# *** BASTION ACL RULE ***

resource "aws_network_acl_rule" "nar_template_public_ingress_22" {
	network_acl_id = aws_network_acl.nac_template_public.id
	rule_number    = 22
	protocol       = "tcp"
	rule_action    = "allow"
	cidr_block     = "0.0.0.0/0"
	from_port      = 22
	to_port        = 22
}


resource "aws_network_acl_rule" "nar_template_public_ingress_65535" {
    network_acl_id = aws_network_acl.nac_template_public.id
    rule_number    = 32766
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = "0.0.0.0/0"
    from_port      = 1024
    to_port        = 65535
}


resource "aws_network_acl_rule" "nar_template_public_egress_443" {
    network_acl_id = aws_network_acl.nac_template_public.id
    rule_number    = 443
    egress         = true
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = "0.0.0.0/0"
	from_port      = 443
	to_port        = 443
}


resource "aws_network_acl_rule" "nar_template_public_egress_65535" {
    network_acl_id = aws_network_acl.nac_template_public.id
    rule_number    = 32766
    egress         = true
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = "0.0.0.0/0"
    from_port      = 1024
    to_port        = 65535
}


# *** PRIVATE SECURITY GROUP ***

resource "aws_default_security_group" "dsg_template_private" {
    vpc_id = aws_vpc.vpc_template.id
}


# *** BASTION SECURITY GROUP ***

resource "aws_security_group" "sgr_template_bastion" {
    vpc_id = aws_vpc.vpc_template.id
}


# *** BASTION SECRUITY GROUP RULE ***

resource "aws_security_group_rule" "sgr_template_bastion_ingress_22" {
	security_group_id = aws_security_group.sgr_template_bastion.id
	type              = "ingress"
	protocol          = "tcp"
	cidr_blocks       = [ "0.0.0.0/0" ]
	from_port         = 22
	to_port           = 22
}


resource "aws_security_group_rule" "sgr_template_bastion_egress_443" {
    security_group_id = aws_security_group.sgr_template_bastion.id
    type              = "egress"
    protocol          = "tcp"
    cidr_blocks       = [ "0.0.0.0/0" ]
    from_port         = 443
    to_port           = 443
}


# *** PRIVATE SUBNET ***

resource "aws_subnet" "sbn_template_private_a" {
	vpc_id            = aws_vpc.vpc_template.id
	cidr_block        = var.sbn_cidr_block_private_a
	availability_zone = "${var.region}a"
}


resource "aws_subnet" "sbn_template_private_b" {
    vpc_id            = aws_vpc.vpc_template.id
    cidr_block        = var.sbn_cidr_block_private_b
    availability_zone = "${var.region}b"
}


resource "aws_subnet" "sbn_template_private_c" {
    vpc_id            = aws_vpc.vpc_template.id
    cidr_block        = var.sbn_cidr_block_private_c
    availability_zone = "${var.region}c"
}


# *** PUBLIC SUBNET ***

resource "aws_subnet" "sbn_template_public_a" {
    vpc_id            = aws_vpc.vpc_template.id
    cidr_block        = var.sbn_cidr_block_public_a
    availability_zone = "${var.region}a"
}


resource "aws_subnet" "sbn_template_public_b" {
    vpc_id            = aws_vpc.vpc_template.id
    cidr_block        = var.sbn_cidr_block_public_b
    availability_zone = "${var.region}b"
}


resource "aws_subnet" "sbn_template_public_c" {
    vpc_id            = aws_vpc.vpc_template.id
    cidr_block        = var.sbn_cidr_block_public_c
    availability_zone = "${var.region}c"
}