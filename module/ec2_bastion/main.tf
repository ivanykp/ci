data "aws_ami" "ami_template_bastion" {
    owners = [ "309956199498" ]
    
    filter {
        name   = "name"
        values = [ "RHEL-8*" ]
    }
    
    filter {
        name   = "architecture"
        values = ["x86_64"]
    }
  
    most_recent = true
}


resource "aws_instance" "ins_template_bastion" {
    ami           = data.aws_ami.ami_template_bastion.id
    instance_type = var.instance_type
    
    root_block_device {
        volume_size = 10
        encrypted   = true
        kms_key_id  = var.kky.id
    }
    
    network_interface {
        network_interface_id = aws_network_interface.nin_template_bastion.id
        device_index         = 0
    }
    
    key_name = var.kpr.key_name

	provisioner "remote-exec" {
		connection {
			host        = aws_eip.eip_template_bastion.public_ip
			private_key = file (var.kpr_private_key)
			user        = "ec2-user"
		}
		inline = [
			"sudo yum update -y",
			"sudo yum install -y unzip",
			"curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip",
            "unzip awscliv2.zip",
            "sudo ./aws/install",
            "rm awscliv2.zip",
			"sudo yum install -y postgresql"
		]
	}
	
	lifecycle {
        ignore_changes = [
            root_block_device
        ]
    }
}


resource "aws_network_interface" "nin_template_bastion" {
    subnet_id       = var.sbn.id
    security_groups = [ var.sgr.id ]
}


resource "aws_eip" "eip_template_bastion" {
    network_interface = aws_network_interface.nin_template_bastion.id
}