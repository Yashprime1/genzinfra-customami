packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "elastic_38"
  instance_type = "t2.micro"
  region        = "eu-west-1"
  source_ami_filter {
    filters = {
      name                = "bamboo-elastic-ami-ubuntu-1696955431"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["200193376361"]
  }
  ssh_username = "ubuntu"
  iam_instance_profile = "ec2fullaccess_role"
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
    script       = "bootstrap.sh"
    execute_command = "echo 'packer' | sudo -S env {{ .Vars }} {{ .Path }}"
  }
}
