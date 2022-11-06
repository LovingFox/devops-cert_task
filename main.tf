# main.tf

######
# create ec2 builder security group
resource "aws_security_group" "sg_builder" {
  name = var.securityGroupBuilder
  description = "[Terraform] Builder ACL"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
######

# create ec2 builder instance
resource "aws_instance" "builder_instance" {
  ami                        = var.ami
  instance_type              = var.instanceType
  key_name                   = var.keyName
  vpc_security_group_ids     = [ aws_security_group.sg_builder.id ]

  tags = {
    Name = var.instanceNameBuilder
  }

  volume_tags = {
    Name = var.instanceNameBuilder
  }
}

# end of main.tf
