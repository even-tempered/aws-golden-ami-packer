packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source = "github.com/hashicorp/amazon"
    }
     ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

variable "region" {
  type    = string
  default = "us-west-2"
}
variable "password" {
  type    = string
  default= "default_password"
}
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source.
source "amazon-ebs" "windows-packer" {
  ami_name      = "packer-windows-demo-${local.timestamp}"
  communicator  = "winrm"
  instance_type = "t3.medium"
  associate_public_ip_address = true
  region        = "${var.region}"
  source_ami_filter {
    filters = {
      name                = "Windows_Server-2019-English-Full-Base*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  user_data_file = "./bootstrap_win.txt"
  winrm_username = "Administrator"
}

# a build block invokes sources and runs provisioning steps on them.
build {
  name    = "windows-packer"
  sources = ["source.amazon-ebs.windows-packer"]

provisioner "ansible" {
     playbook_file   = "./ec2launch.yml"
     use_proxy       = false
     user            = "Administrator"
  }
 
 provisioner "file" {
    source      = "./unattend.xml"
    destination = "C:\\ProgramData\\Amazon\\EC2Launch\\sysprep\\unattend.xml"
    content     = templatefile("././unattend.xml", { password = var.password })
  }

 provisioner "file" {
    source      = "./agent-config.yml"
    destination = "C:\\ProgramData\\Amazon\\EC2Launch\\config\\agent-config.yml"
  }

  provisioner "powershell" {
    inline = [
      "& 'C:/Program Files/Amazon/EC2Launch/ec2launch' reset --block",
      "& 'C:/Program Files/Amazon/EC2Launch/ec2launch' sysprep --shutdown --block"
    ]
  }
 
  post-processors {
    # Post-processing steps here
  }
  
}
