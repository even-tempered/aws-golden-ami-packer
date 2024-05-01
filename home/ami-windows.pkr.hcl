variable "ami_name" {
  type = string
  default = "custom-windows-{{timestamp}}"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

# https://www.packer.io/docs/builders/amazon/ebs
source "amazon-ebs" "windows" {
  ami_name = "ec2launchv2_${var.ami_name}"
  instance_type = "t3.medium"
  region = "${var.region}"
  associate_public_ip_address = true
  source_ami_filter {
    filters = {
      name = "Windows_Server-2019-English-Full-Base-*"
      root-device-type = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners = ["amazon"]
  }
  communicator = "winrm"
  winrm_username = "Administrator"
  winrm_port = 5985
  winrm_use_ssl = true
  winrm_insecure = true
  user_data_file = "./winrm_bootstrap.txt"
}

# https://www.packer.io/docs/provisioners
build {
  sources = ["source.amazon-ebs.windows"]

# provisioner "file" {
 #   source      = "./unattend.xml"
 #   destination = "C:\\Windows\\Panther\\Unattend\\unattend.xml"
 # }

  provisioner "ansible" {
     playbook_file   = "./ec2launch.yml"
     use_proxy       = false
  }

 #provisioner "powershell" {
 #   inline = [
 #     "Write-Output 'Injecting Unattend.xml file'",
 #     "Get-ChildItem 'C:\\Windows\\Panther\\Unattend\\unattend.xml'"
 #   ]
 # }
 provisioner "powershell" {
    inline = [
      "Write-Output 'Running sysprep...'",
      "C:\\Windows\\System32\\Sysprep\\Sysprep.exe /generalize /oobe /quit /quiet /unattend:C:\\Windows\\Panther\\Unattend\\unattend.xml",
      "Write-Output 'InitializeInstance.ps1'",
      "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\InitializeInstance.ps1 -Schedule",
      "Write-Output 'running EC@LAUNCH'",
      "& 'C:/Program Files/Amazon/EC2Launch/ec2launch' reset --block",
      "& 'C:/Program Files/Amazon/EC2Launch/ec2launch' sysprep --shutdown --block",
      "Write-Output 'running setting password'",
      "net user Administrator Saurabh@123"
    ]
  }
 
  post-processors {
    # Post-processing steps here
  }
  
}
