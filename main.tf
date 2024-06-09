provider "aws" {
  region = "us-west-2"
}

variable "public_key_path" {
  description = "Path to the public key to be used for SSH access"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private key to be used for SSH access"
  type        = string
}

# No need for aws_key_pair resource since we're using an existing key pair

resource "aws_security_group" "minecraft_sg" {
  name_prefix = "minecraft_sg"

  // Allow SSH traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow Minecraft traffic
  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "minecraft" {
  ami             = "ami-0cf2b4e024cdb6960"  # Amazon Linux 2 AMI for us-west-2 region
  instance_type   = "t2.micro"
  key_name        = "lab6keys"  # Use the existing key pair name
  security_groups = [aws_security_group.minecraft_sg.name]

  provisioner "local-exec" {
    command = "sleep 60"  # Wait for the instance to initialize
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user",
      "sudo docker run -d --restart=always -p 25565:25565 --name minecraft-server itzg/minecraft-server"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)  # Use the lab6keys.pem private key
      host        = self.public_ip
    }
  }

  tags = {
    Name = "MinecraftServer"
  }
}

output "instance_public_ip" {
  value = aws_instance.minecraft.public_ip
}
