# variables.tf

variable "region" {
   default = "eu-central-1"
}

variable "instanceType" {
   default = "t2.micro"
}

# Ubuntu 22.04
variable "ami" {
   default = "ami-0caef02b518350c8b"
}

variable "keyName" {
   default = "devops-cert_task-key"
}

#####################
# builder vars
variable "instanceNameBuilder" {
   default = "devops-cert_task-builder"
}

variable "securityGroupBuilder" {
   default = "devops-cert_task-builder-sg"
}

#####################
# webserver vars
variable "instanceNameWebserver" {
   default = "devops-cert_task-webserver"
}

variable "securityGroupWebserver" {
   default = "devops-cert_task-webserver-sg"
}

# end of variables.tf
