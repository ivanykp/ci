# *** CLUSTER ***

resource "aws_rds_cluster" "rcl_template" {
    engine                          = "aurora-postgresql"
    vpc_security_group_ids          = [ aws_security_group.sgr_template_rds.id ]
    db_subnet_group_name            = aws_db_subnet_group.dsg_template.name
    db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.rcp_template.name
    storage_encrypted               = true
    kms_key_id                      = var.kky.arn
    preferred_backup_window         = var.rcl_backup_window
    preferred_maintenance_window    = var.rcl_maintenance_window
    enabled_cloudwatch_logs_exports = [ "postgresql" ]
    master_username                 = var.rcl_username
    master_password                 = var.rcl_password

    skip_final_snapshot       = true
    final_snapshot_identifier = "final-rcl-template"
    apply_immediately         = true
}


# *** IAM ROLE & POLICY ***

resource "aws_iam_role" "rds_enhanced_monitoring" {
    name_prefix        = "rds-enhanced-monitoring-"
    assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}


resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
    role       = aws_iam_role.rds_enhanced_monitoring.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}


data "aws_iam_policy_document" "rds_enhanced_monitoring" {
    statement {
        actions = [ "sts:AssumeRole" ]
        effect  = "Allow"
        principals {
            type        = "Service"
            identifiers = [ "monitoring.rds.amazonaws.com" ]
        }
    }
}


# *** INSTANCE ***

resource "aws_rds_cluster_instance" "rci_template_a" {
    cluster_identifier           = aws_rds_cluster.rcl_template.id
    engine                       = aws_rds_cluster.rcl_template.engine
    instance_class               = var.instance_class
    monitoring_role_arn          = aws_iam_role.rds_enhanced_monitoring.arn
    monitoring_interval          = 60
    preferred_maintenance_window = var.rcl_maintenance_window
}


resource "aws_rds_cluster_instance" "rci_template_b" {
    cluster_identifier           = aws_rds_cluster.rcl_template.id
    engine                       = aws_rds_cluster.rcl_template.engine
    instance_class               = var.instance_class
    monitoring_role_arn          = aws_iam_role.rds_enhanced_monitoring.arn
    monitoring_interval          = 60
    preferred_maintenance_window = var.rcl_maintenance_window
}


# *** NETWORK ACL ***

resource "aws_network_acl_rule" "nar_template_private_ingress_5432_a" {
    network_acl_id = var.dna_private.id
    rule_number    = 100
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = var.sbn_public_a.cidr_block
    from_port      = 5432
    to_port        = 5432
}


resource "aws_network_acl_rule" "nar_template_private_ingress_5432_b" {
    network_acl_id = var.dna_private.id
    rule_number    = 101
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = var.sbn_public_b.cidr_block
    from_port      = 5432
    to_port        = 5432
}


resource "aws_network_acl_rule" "nar_template_private_ingress_5432_c" {
    network_acl_id = var.dna_private.id
    rule_number    = 102
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = var.sbn_public_c.cidr_block
    from_port      = 5432
    to_port        = 5432
}


resource "aws_network_acl_rule" "nar_template_private_egress_65535_a" {
    network_acl_id = var.dna_private.id
    rule_number    = 997
    egress         = true
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = var.sbn_public_a.cidr_block
    from_port      = 1024
    to_port        = 65535
}


resource "aws_network_acl_rule" "nar_template_private_egress_65535_b" {
    network_acl_id = var.dna_private.id
    rule_number    = 998
    egress         = true
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = var.sbn_public_b.cidr_block
    from_port      = 1024
    to_port        = 65535
}


resource "aws_network_acl_rule" "nar_template_private_egress_65535_c" {
    network_acl_id = var.dna_private.id
    rule_number    = 999
    egress         = true
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = var.sbn_public_c.cidr_block
    from_port      = 1024
    to_port        = 65535
}


# *** SECURITY GROUP ***

resource "aws_security_group" "sgr_template_rds" {
    vpc_id = var.vpc.id
}


resource "aws_security_group_rule" "sgr_template_rds_ingress_5432" {
    security_group_id = aws_security_group.sgr_template_rds.id
    type              = "ingress"
    protocol          = "tcp"
    
    cidr_blocks = [
        var.sbn_public_a.cidr_block,
        var.sbn_public_b.cidr_block,
        var.sbn_public_c.cidr_block
	]
	
    from_port = 5432
    to_port   = 5432
}


resource "aws_security_group_rule" "sgr_template_rds_egress_65535" {
    security_group_id = var.sgr_bastion.id
    type              = "egress"
    protocol          = "tcp"
   
    cidr_blocks = [
        var.sbn_private_a.cidr_block,
        var.sbn_private_b.cidr_block,
        var.sbn_private_c.cidr_block
    ]
    from_port = 5432
    to_port   = 5432
}


# *** DATABASE SUBNET GROUP ***

resource "aws_db_subnet_group" "dsg_template" {
    name       = "dsg_template"
    subnet_ids = [
        var.sbn_private_a.id,
        var.sbn_private_b.id,
        var.sbn_private_c.id
    ]
}


# *** CLUSTER PARAMETER GROUP ***

resource "aws_rds_cluster_parameter_group" "rcp_template" {
	family = "aurora-postgresql11"
	
	parameter {
		name  = "rds.force_ssl"
		value = "1"
	}
	
	parameter {
		name         = "shared_preload_libraries"
		value        = "pgaudit"
		apply_method = "pending-reboot"
	}
	
	parameter {
		name         = "pgaudit.role"
		value        = "rds_pgaudit"
		apply_method = "pending-reboot"
	}
	
	parameter {
		name         = "pgaudit.log"
		value        = "role,ddl"
		apply_method = "pending-reboot"
	}
}


# *** LOG GROUP ***

resource "aws_cloudwatch_log_group" "clg_template" {
	name              = "/aws/rds/cluster/${aws_rds_cluster.rcl_template.id}/postgresql"
	retention_in_days = 30
}


resource "aws_cloudwatch_log_group" "clg_template_os" {
    name              = "RDSOSMetrics"
    retention_in_days = 30
}


# *** EXECUTION ***

resource "null_resource" "nrs_template_rds_audit_role_create" {
    provisioner "remote-exec" {
        connection {        
            host        = var.ec2_bastion
            private_key = file (var.kpr_private_key)
            user        = "ec2-user"
        }
		inline = [
			"psql postgres://${var.rcl_username}:${var.rcl_password}@${aws_rds_cluster_instance.rci_template_a.endpoint} -c 'CREATE ROLE rds_pgaudit;'"
		]
	}

	depends_on = [
		aws_rds_cluster.rcl_template,
		aws_rds_cluster_instance.rci_template_a,
		aws_security_group.sgr_template_rds
	]
}