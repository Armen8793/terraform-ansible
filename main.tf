
locals {
  ssh_user = "ubuntu"
  key_name = "anster"
  private_key_path = "/home/armen/Downloads/anster.pem"
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "web" {
  ami 			      = data.aws_ami.ubuntu.id
  instance_type 	      = "t2.micro"
  associate_public_ip_address = true 
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = local.key_name

  tags = {
    Name = "Web"
    Value = "Armen"
  }

  provisioner "remote-exec" {
  inline = [
    "sudo apt update",
    "sudo apt install python3",
    "sudo apt install ansible",
  ]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.web.public_ip
    }
  } 

  provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.web.public_ip} --private-key ${local.private_key_path} nginx.yaml"
  }  

}

resource "aws_security_group" "web" {
  name        = "ACA Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  tags = {
    Name  = "Ansible"
    Owner = "Armen Petrosyan"
  }
}


