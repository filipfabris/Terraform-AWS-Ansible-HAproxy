
variable "project_name" {
    description = "AWS proba"
    type = string
    default = "Rama"
}

variable "region" {
    description = "AWS Region"
    type = string
    default = "us-east-1"
}



variable "web_ami" {
    description = "AMI for Web instances"
    type = string
    default = "ami-05fa00d4c63e32376"
}

variable "web_instance_type" {
    description = "Instance type for Web instances"
    type = string
    default = "t2.micro"
}

variable "web_hostname" {
    description = "Hostname for Web instances"
    type = string
    default = "alation-web"
}

variable "desired_web_server_count" {
    type = number
    default = 2
}





variable "load_balancer_ami" {
    description = "AMI for Load Balancer instance"
    type = string
    default = "ami-05fa00d4c63e32376"
}

variable "load_balancer_instance_type" {
    description = "Instance type for Load Balancer instance"
    type = string
    default = "t2.micro"
}

variable "load_balancer_hostname" {
    description = "Hostname for Load Balancer instance"
    type = string
    default = "alation-lb"
}

# personal variables, should only be entered in `terraform.tfvars` file
variable "aws_pem_key_file_path" {}
variable "aws_pub_key_file_path" {}
variable "aws_key_name" {}

# secret variables, should also only be entered in `terraform.tfvars` file
variable "aws_access_key" {}
variable "aws_secret_key" {}
