resource "aws_key_pair" "deployer" {
  key_name   = "terra-automate-key"
  public_key = file("terra-key-ec2.pub")
}

resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "allow_user_to_connect" {
  name        = "allow TLS"
  description = "Allow user to connect"
  vpc_id      = aws_default_vpc.default.id
  ingress {
    description = "port 22 allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = " allow all outgoing traffic "
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "port 80 allow"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "port 443 allow"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-security"
  }
}

resource "aws_instance" "my_instance" {
  ami             = "ami-02b8269d5e85954ef"
  instance_type   = "t3.micro"
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.allow_user_to_connect.name]
  tags = {
    Name = "Terra-Automate"
  }
  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("terra-key-ec2")
    host        = self.public_ip
  }
}
