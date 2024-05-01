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
  ami_name = "${var.ami_name}"
  instance_type = "t3.medium"
  region = "${var.region}"
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
  winrm_use_ssl = true
  winrm_insecure = true

  # This user data file sets up winrm and configures it so that the connection
  # from Packer is allowed. Without this file being set, Packer will not
  # connect to the instance.
  user_data_file = "./winrm_bootstrap.txt"
}

# https://www.packer.io/docs/provisioners
build {
  sources = ["source.amazon-ebs.windows"]
  

  provisioner "powershell" {
    script = "./df.ps1"
  }

  provisioner "file" {
    source      = "./unattend.xml"
    destination = "C:\\unattend.xml"
  }
 
  provisioner "windows-restart" {
    restart_timeout = "10m"
    restart_check_command = "powershell -command \"& { Write-Host 'Waiting for restart...'; sleep 30; }\""
  }
 
  provisioner "powershell" {
    inline = [
      "net user Administrator Password@123"
    ]
    when = "after"
  
}
